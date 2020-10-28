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
    
    mutating func add(_ cardToAdd: Card, toColumn to: Int) {
        // Add the card to the appropriate column of cards
        tableau.columns[to]!.cards.append(cardToAdd)
        
        // We moved a card, so let's add a Move record to indicate that
        moveNum += 1
        let move = Move(turn: moveNum, card: cardToAdd, from: "Stock", to: "Col" + String(to))
        moves.append(move)
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
                return false
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
    
    mutating func playStock() {
        var keepPlaying = true
        
        repeat {
            // Get the right number of cards we need for this round
            self.fillPlayableStockCards()
            
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
                // or tableau, add the card to the waste
                if wasAbleToMove == false {
                    self.waste.cards.append(card)
                    // and we're done with the stock
                    keepPlaying = false
                }
            }
        } while keepPlaying == true
    }
}
