//
//  game+stock_logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/18/20.
//

import Foundation

extension Game {
    // This function removes the cards from the stock
    mutating func dealCardsFromStock(amount: Int) -> [Card] {
        // Make sure we can deal out the right number
        // of cards asked for
        assert(amount <= self.stock.cards.count)
        
        var cards = [Card]()
        var i = 1
        for (_, card) in self.stock.cards.enumerated().reversed() {
            // Add the card to our array...
            cards.append(card)
            // ... and *remove* it from the stock; if the card comes
            // back to the stock it's because it couldn't be played (yet)
            // on the tableau or foundation
            self.stock.cards.removeLast()
            
            // Do we have the amount of cards we need?
            if i == amount {
                // Yep, so we're done
                break
            } else {
                // Nope, keep going
                i += 1
            }
        }
        
        // Okay, we're returning the cards, but not in playable
        // order. That will be done by the caller
        return cards
    }
    
    mutating func playStock() {
        var cardsToPlay = self.dealCardsFromStock(amount: 3)
        // Now let's see if we can play these cards on the foundations
        for (i, card) in cardsToPlay.enumerated().reversed() {
            let wasAbleToMove = tryToMoveToFoundation(card)
            if wasAbleToMove {
                // If we played it, remove it from our list
                cardsToPlay.remove(at: i)
            } else {
                // Okay, we weren't able to move the card to the
                // foundation, so let's see if we can move to a column
                // on the tableu
                
            }
        }
    }
}
