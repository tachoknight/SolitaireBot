//
//  game+stock_logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/18/20.
//

import Foundation

extension Game {
    
    // This function removes the cards from the stock
    mutating func dealCards(amount: Int) -> [Card] {
        var cards = [Card]()
        var i = 1
        for (_, card) in self.stock.cards.enumerated().reversed() {
            cards.append(card)
            self.stock.cards.removeLast()
            
            // Do we have the amount of cards we need?
            if i == amount {
                break
            } else {
                i += 1
            }
        }
        
        // Okay, now we return the cards reversed, as the last
        // card we added is the first card we want to play
        return cards.reversed()
    }
    
    mutating func playStock() {
        self.stock.printPile("Stock before getting cards")
        print("====== Cards to play:")
        var cardsToPlay = dealCards(amount: 3)
        for card in cardsToPlay {
            print(card)
        }
        print("======")
        self.stock.printPile("Stock after")
    }
}
