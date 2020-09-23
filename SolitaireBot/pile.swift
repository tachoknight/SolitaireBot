//
//  pile.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/17/20.
//

import Foundation

// A pile refers to a stack of cards and is used as the
// basis for holding cards in every facet of the game

struct Pile {
    var cards = [Card]()
}

extension Pile {
    func printPile(_ pileName: String) {
#if DEBUG
        print("\(pileName) cards --->")
        for card in cards {
            print(card)
        }
        print("<--- \(pileName) cards")
#endif
    }
}
