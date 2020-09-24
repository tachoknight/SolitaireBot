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

    mutating func newWith(_ deck: inout [Card]) {
        print("Creating new tableau...")
        self.columns = newTableau(&deck)
        printTableau(showAllCards: true)
    }
    
    // This function sets up the traditional starting positions
    // for the cards
    func newTableau(_ deck: inout [Card]) -> [Int: Pile] {
        // This algorithm works by first setting up the arrays
        // as values to the keys which are the columns of the
        // tableau...
        var tempColumns = [Int: Pile]()
        for col in 0...COLUMNS {
            let pile = Pile()
            tempColumns[col] = pile
        }

        // ...and we go row-by-row, column-by-column, to
        // lay out the cards, as this is the traditional way
        // in the game to build the initial tableau
        for row in 0...COLUMNS {
            for col in 0...COLUMNS {
                if row <= col {
                    var card = deck.removeFirst()
                    if row == col {
                        card.face = .up
                    } else {
                        card.face = .down
                    }
                    tempColumns[col]?.cards.append(card)
                }
            }
        }

        return tempColumns        
    }
}

// Mark: - Counts
extension Tableau {
    func totalCardCount() -> Int {
        var totalCards = 0;
        
        for col in 0...COLUMNS {
            totalCards += self.columns[col]?.cards.count ?? 0
        }
        
        return totalCards
    }
}

// Mark: - Debugging/printing
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
                let cards = pile?.cards
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
