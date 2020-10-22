//
//  game+foundation_logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/22/20.
//

import Foundation

extension Game {
    mutating func tryToMoveToFoundation(_ card: Card) -> Bool {
        var successfullyMovedToFoundation = false
        
        // Get the pile of cards for this foundation
        // Note the pile may be empty
        var foundationPile = foundations[card.suit]?.pile
            
        // First let's get the top-most card (i.e. last) from the
        // foundation pile...
        let topFoundationCard = foundationPile?.cards.last
            
        // ... and now we compare it to the test card. We have a
        // static subtraction operator in the Rank enum so we
        // can perform a simple subtraction. The only way our
        // test card gets put onto the foundation pile is if
        // it is one greater than the current top foundation card
        // (e.g. 2 is greater than ace, but 7 is not one greater
        // than 5, etc.)
        if card.rank - topFoundationCard!.rank != 1 {
            return false
        } else {
            // Oh, nice, we can put this card on the foundation
            foundationPile?.cards.append(card)
            // And tell the caller we were succesful
            successfullyMovedToFoundation = true
        }
        
        // And assign it back
        self.foundations[card.suit]?.pile = foundationPile.fu(because: "We should have a card in the pile here because otherwise we would have already returned from the function")
        
        return successfullyMovedToFoundation
    }
}
