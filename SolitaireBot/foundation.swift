//
//  foundation.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/17/20.
//

import Foundation

// This file contains everything necessary to handle a foundation, which
// is the pile of cards that is the ultimate destination for the game (i.e.
// the game is won when all the cards are in their respective suit foundations)

struct Foundation {
    var suit: Suit
    var pile: Pile
    
    public init(suit: Suit) {
        self.suit = suit
        self.pile = Pile()
    }
}

// MARK: - Counts
extension Foundation {
    func count() -> (Suit, Int) {
        return (self.suit, self.pile.cards.count)
    }
}

// MARK: - Printing
extension Foundation {
    func printTopCard() {
        let cardToShow = pile.cards.last
        print("Foundation: \(cardToShow.fu(because: "There should always be a card in the foundation, even a null card").description)")
    }
}
