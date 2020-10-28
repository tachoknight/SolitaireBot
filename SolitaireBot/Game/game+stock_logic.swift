//
//  game+stock_logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/18/20.
//

import Foundation

// This is how many cards to draw from the stock pile
// 1 or 3
let NUMBER_OF_STOCK_CARDS = 3

extension Game {
    // This function removes the cards from the stock
    mutating func drawCardsFromStock(amount: Int) -> [Card] {
        // If we don't have any cards in the stock, then we
        // need to get the waste pile cards over here.
        if self.stock.cards.count == 0 {
            moveWasteToStock()
        }
        
        // Make sure we can deal out the right number
        // of cards asked for, and if there are fewer cards
        // in the pile than we want, then we take whatever we
        // can get
        var trueAmount = amount
        if trueAmount > self.stock.cards.count {
            trueAmount = self.stock.cards.count
        }
        
        // Now let's get the cards
        var cards = [Card]()
        for _ in trueAmount {
            var fuCard = self.stock.cards.removeFirst()
            fuCard.face = .up
            cards.append(fuCard)
        }
     
        // Okay, we're returning the cards, but not in playable
        // order. That will be done by the caller
        return cards
    }
    
    // This function keeps self.stockCardsInPlay; we always want to
    // have three cards unless we literally don't have three cards to
    // give, otherwise we'll keep giving as many as we can
    mutating func fillPlayableStockCards() {
        let numCardsToGet = NUMBER_OF_STOCK_CARDS - self.waste.cards.count
        if numCardsToGet == 0 {
            return
        }
        
        // Get the right number of cards from the stock
        let tempCards = self.drawCardsFromStock(amount: numCardsToGet)
        
        // And add the cards we just got to our playable ones
        for card in tempCards {
            self.waste.cards.append(card)
        }
    }
}
