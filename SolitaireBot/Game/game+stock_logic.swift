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
    // This function draws cards from the stock and
    // puts them on the waste to play
    mutating func addStockCardsToWasteToPlay() {
        // Start with the default number of cards
        // we're supposed to draw
        var numCardsToGet = NUMBER_OF_STOCK_CARDS
        
        // If there are not enough cards in the stock,
        // get as many as we can
        if numCardsToGet > self.stock.cards.count {
            numCardsToGet = self.stock.cards.count
        }
        
        // Now for each card...
        for _ in numCardsToGet {
            // ... remove it from the stock ...
            var fuCard = self.stock.cards.removeFirst()
            // ... and set it as face up ...
            fuCard.face = .up
            // ... and insert it at the bottom of the
            // the waste.
            // HOWEVER! This is not how the
            // game is played, the last card that is
            // dealt is the first card we play. That is
            // handled by the caller which will roll through
            // the waste array in reverse order, so the
            // last card we append here will, in fact, be the
            // first card played
            self.waste.cards.append(fuCard)
        }
    }
}
