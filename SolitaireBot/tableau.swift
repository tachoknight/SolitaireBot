//
//  tableau.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/17/20.
//

import Foundation

// The number of columns in the tableau (7), but
// we're subtracting 1 so we can work with it in
// arrays
let COLUMNS = (7 - 1)

// The Tableau refers to the piles on the table that the player
// moves the cards around to and from. In Klondike Solitare there
// are seven of them
struct Tableau {
    // This is a dictionary, which is unordered, but that's okay
    // because we're always accessing it via the key which is the
    // column number (0-based) so we'll always get the right pile,
    // even in loops
    var columns = [Int: Pile]()

    // This function sets up the traditional starting positions
    // for the cards
    mutating func resetWith(_ deck: inout [Card]) {
        for col in 0...COLUMNS {
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

            self.columns[col] = pile
        }

        printTableau(showAllCards: true)
    }
}

// Debugging/printing
extension Tableau {
    // Print the entire tableau, as if it were laid out on a table;
    // allowing the user to choose to show all the cards or
    // as a real player would see them (i.e. a mix of face up/face down)
    func printTableau(showAllCards: Bool = false) {
        print("Printing the tableau...")

        var printingDone = false

        var currentRow = 0

        while printingDone == false {
            var cardsInRow = [Card]()

            for col in 0...COLUMNS {
                // We want our pile in reversed order as the oldest card
                // should be at the bottom
                let pile = self.columns[col]
                var cards = pile?.cards
                // cards?.reverse()
                // The column may have no cards at this row, but we need to preserve
                // the columns so we need to add a null card
                let isValidRow = cards?.indices.contains(currentRow) ?? false
                if isValidRow {
                    if let card = cards?[currentRow] {
                        cardsInRow.append(card)
                    }
                } else {
                    let nullCard = Card(rank: .null, suit: .noSuit, face: .noface)
                    cardsInRow.append(nullCard)
                }
            }

            // Now we need to check if the whole row is nothing but Null cards,
            // in which case we're done
            var onlyNullCards = true
            for nullCardTest in cardsInRow {
                if nullCardTest.isNullCard() == false {
                    onlyNullCards = false
                    break
                }
            }

            if onlyNullCards {
                printingDone = true
            } else {
                var lineToPrint = ""

                for card in cardsInRow {
                    lineToPrint += card.fullDescription(shouldShowFace: showAllCards)
                    lineToPrint += "\t"
                }

                print(lineToPrint)

                currentRow += 1
            }
        }
    }
}
