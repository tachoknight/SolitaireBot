//
//  game+waste_logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/22/20.
//

import Foundation

extension Game {
    mutating func moveWasteToStock() {
        print("Moving from waste to stock")
        // Move the cards from the waste to the
        // stock as a copy, setting all the
        // faces to down
        for card in self.waste.cards {
            var fdCard = card
            fdCard.face = .down
            self.stock.cards.append(fdCard)
        }

        // And get rid of the cards in the waste
        self.waste.cards.removeAll()
    }
    
    mutating func add(_ cardToAdd: Card, toColumn to: Int) {
        // Add the card to the appropriate column of cards
        tableau.columns[to]!.cards.append(cardToAdd)
        
        // We moved a card, so let's add a Move record to indicate that
        self.moveNum += 1
        let move = Move(turn: moveNum, card: cardToAdd, from: "Stock", to: "Col" + String(to))
        self.moves.append(move)
    }
    
    mutating func tryToAddToTableau(_ testCard: Card) -> Bool {
        // Okay, let's see if we can add our card to any of the columns
        for col in 0 ... COLUMNS {
            // Is this a King card?
            if testCard.rank == .king, isEmptyForColumn(col) == true {
                // Yes, we can add it!
                self.add(testCard, toColumn: col)
                return true
            }
            
            // The column may be empty, and we don't have a king, in
            // which case we cannot play here
            if isEmptyForColumn(col) == true {
                continue
            }
            
            // Now we need to get the bottom card of the
            // pile for this column, which will be a face card
            // and let's see if we can play on it
            let bottomCard = tableau.columns[col]?.cards.last
            assert(bottomCard?.face == .up)
            
            // And here we see if the card we got from the bottom
            // of the pile can take the test card
            let isPlayable = card(testCard, canBePlayedOn: bottomCard!)
            if isPlayable {
                self.add(testCard, toColumn: col)
                return true
            }
        }
        
        return false
    }
    
    mutating func playFromWaste() {
        // If we don't have any cards in the stock, then we
        // need to get the waste pile cards over here.
        if self.stock.cards.count == 0 {
            self.moveWasteToStock()
        }
  
        // Get the right number of cards we need for this round
        self.addStockCardsToWasteToPlay()

        waste.printPile("waste before")
        
        // Now let's see if we can play these cards on the foundations
        for (i, card) in self.waste.cards.enumerated().reversed() {
            // Can we move the card to the foundation?
            var wasAbleToMove = tryToMoveToFoundation(card)
            if wasAbleToMove {
                // If we played it, remove it from our list
                self.waste.cards.remove(at: i)
            } else {
                // Okay, we weren't able to move the card to the
                // foundation, so let's see if we can move to a column
                // on the tableu
                wasAbleToMove = self.tryToAddToTableau(card)
                if wasAbleToMove {
                    // Yay, we played it, so remove it from our list
                    self.waste.cards.remove(at: i)
                }
            }
            
            // If we couldn't play on either the foundation
            // or tableau, we're done working with the waste
            // for the time being
            if wasAbleToMove == false {
                break
            }
        }
    }
}
