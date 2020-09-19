//
//  tableau.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/17/20.
//

import Foundation

// The Tableau refers to the piles on the table that the player
// moves the cards around to and from. In Klondike Solitare there
// are seven of them
struct Tableau {
    var columns = [[Pile]]()
    
    // This function sets up the traditional starting positions
    // for the cards
    mutating func resetWith(_ deck: inout [Card]) {
        for col in 0...6 {
            var pile = Pile()
            for row in 0...col {
                var card = deck.removeFirst()
                if row == col {
                    card.face = .up
                } else {
                    card.face = .down
                }
                pile.cards.append(card)
            }
         
            self.columns.append([pile])
        }
    }
}

// Debugging/printing
extension Tableau {
    // Print the entire tableau, as if it were laid out on a table;
    // allowing the user to choose to show all the cards or
    // as a real player would see them (i.e. a mix of face up/face down)
    func printTableau(showAllCards: Bool = false) {
        
    }
}
