//
//  game+logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/24/20.
//

import Foundation

// Okay, the way we're going to play is to look at the columns, left-to-right,
// at all the cards that are face-up and check the following in this order:
//  1.  Is there a card below it (i.e. it's not at the bottom). If there *is* a
//      card below it, then the card is not eligible to be put on a foundation so
//      won't test for that.
//  2.  If the card does *not* have a card below it (i.e. it is at the bottom of the column),
//      then we will see if we can put it on on a foundation
//  3.  If the card cannot be put on a foundation, can it be put on another column in the
//      tableau? Note that Kings can only be put on empty columns, so if the card is a king,
//      we have to look for an empty column
//
//      HEY READ THIS! At the moment, just to get the basic game logic going, we are going to
//      play naively and pick the first column we can move to; there may be another column but
//      we're going to stop at the first one we find (if we find one). Later iterations of the
//      software will do both; the intention is to always fork off the game at a point like this
//      so we can test all possible scenarios for a specific deal and ultimately record every.
//      single. way to play a particular hand and record all of it.
//
//  4.  If the card was moved to another column, flip up the card below it (if there is one)
//      and repeat from #1
//  5.  If there are no playable cards on the tableau, deal three cards from the stock and
//      put them on the waste
//  6.  Use the logic from above to see if the card that is at the top of the waste is playable.
//  7.  If the card from the top of the waste was played, go through the columns again (except the column
//      we just added the card to see if there is an opportunity to move cards to it.
//
//      HEY READ THIS! Similar to #3, we are going to naively move the cards, if possible, to the
//      card just played, even though there may be another playable card. Similarly to #3 this is
//      where a forking point would occur, where the game will split into one where the first card
//      was used, and the other game would play on the second card
//
//  8.  If we were able to play the card from the top of the waste, go to the next card at the top of the
//      waste pile and repeat from #5
//  9.  If there are < 3 cards in the stock, transfer the waste back to the stock use deal three new
//      cards, using however many cards were there at the top
//  10. Game is lost if no cards move from the waste to the tableau in two passes
//  11. Game is won if all the cards on the tableau can be uncovered

// MARK: - Logic

extension Game {
    // Check if the column is empty (so is eligible for a king to
    // be played on it)
    func isEmptyForColumn(_ col: Int) -> Bool {
        return tableau.columns[col]?.cards.count == 0
    }
    
    func getFaceUpCards(_ pile: Pile) -> [Card] {
        var fuCards = [Card]()
        
        for card in pile.cards {
            if card.face == .up {
                fuCards.append(card)
            }
        }
        
        // There must *always* be a face-up card
        assert(fuCards.count > 0)
        return fuCards
    }
    
    // This is the biggie. This function determines whether our "from" card can
    // be played on the "to" card (i.e. the card we're trying to move (from) to the
    // card at the bottom of a column (to)). We have to take into consideration the
    // color of the card (but not the suit), and the card value. For example, a black
    // two can only be played on top of a red three, and a red jack can only be played
    // on top of a black queen.
    func card(_ from: Card, canBePlayedOn to: Card) -> Bool {
        // first test, are the two cards the same color? If so, then
        // we can just call it early and return false
        if from.suit.color() == to.suit.color() {
            // Same colors, so we're out
            return false
        }
        
        // Okay, if we're here, then the two cards are different
        // colors so now we have to see if the From card is exactly
        // one less in value than the To card
        if to.rank.rawValue - from.rank.rawValue == 1 {
            // Woo, yes, the card we're trying to play (from)
            // is one less in value than the card we're trying to it
            // below (to). This means the from card will be able to be
            // added to the pile of cards that to is at the bottom
            // of
            return true
        }
        
        // Nope, the cards are too far apart from each other so this is
        // not a playable combination
        return false
    }
    
    // If this function is getting called, then we have the ability to move
    // a card(s) from one column to another. "Card(s)" because the card we're
    // moving may have cards below it
    // This is an expensive function, because it has to find the card
    // in the pile of cards in the From, and actually move it *and all
    // subsequent cards* to the To pile
    mutating func move(_ cardToMove: Card, fromColumn from: Int, toColumn to: Int) {
        /*
         if cardToMove.rank == .jack && cardToMove.suit == .clubs {
             print("This is the card to check")
         }
         */
        
        var cardsBeingMoved = [Card]()
        var foundCard = false
        var rowPosition = 0
        for card in tableau.columns[from].fu(because: "There should be a card in this column to move").cards {
            // Loop through the pile looking for the card we're going to move...
            if card == cardToMove {
                // ... which we found ...
                foundCard = true
            }
            
            // If we found the card, then we are going to move the card
            // to the new location and remove it from the old location
            if foundCard {
                // Remove the card from the From column
                var cardToMove = tableau.columns[from]!.cards.remove(at: rowPosition)
                // And make sure it's face up
                cardToMove.face = .up
                // And add it to the To column
                tableau.columns[to]!.cards.append(cardToMove)
                // And also add it to our cardsBeingMoved array for documenting it
                cardsBeingMoved.append(cardToMove)
            }
            
            rowPosition += 1
        }
        
        // We moved one or more cards, so let's add a Move record to indicate that
        moveNum += 1
        let move = Move(turn: moveNum, cards: cardsBeingMoved, from: "Col" + String(from), to: "Col" + String(to))
        moves.append(move)
    }
    
    // This function is responsible for taking an array of cards
    // and the originating column and looking at the other columns'
    // bottom card and see if it's playable
    mutating func tryToMoveAroundTableau(_ testCard: Card, from: Int) -> (Bool, Int) {
        // So now let's go through the columns other than the one
        // we came from
        for col in 0...COLUMNS {
            if col == from {
                // skip the column we came from
                continue
            }
            
            // There may be no cards in this column, in which case we won't
            // do anything with it unless we're playing a King, which can
            // *only* go on a free column (i.e. a column with no cards)

            // Is this a King card?
            if testCard.rank == .king, isEmptyForColumn(col) == true {
                // We can play a king on this column!
                move(testCard, fromColumn: from, toColumn: col)
                return (true, col)
            }
            
            // We do not have a King card, but we still need to
            // validate that there are cards in this column to
            // test, otherwise we're going to skip this column
            // entirely
            if isEmptyForColumn(col) {
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
                // Okay, great, the card is playable, in which case we want to
                // move it (and any cards under it) to the new column
                move(testCard, fromColumn: from, toColumn: col)
                return (true, col)
            }
        }
        
        return (false, -1)
    }
    
    // This card takes an array of cards we want to prune, using the
    // cardsToRemove array, returning a new array with only the cards
    // in the from array that were not in the cardsToRemove array
    func removeCards(from: [Card], cardsToRemove: [Card]) -> [Card] {
        var prunedCards = [Card]()
        
        for testCard in from {
            var foundCard = false
            for removeCard in cardsToRemove {
                if testCard == removeCard {
                    foundCard = true
                }
            }
            
            if foundCard == false {
                prunedCards.append(testCard)
            }
        }
        
        return prunedCards
    }
    
    mutating func playColumn(_ col: Int) {
        // This bool tells us whether we should keep playing the cards
        // in the column. Even though we're going through each card in
        // succession, we may end up moving cards around that would impact
        // further play (e.g. we moved more than one card at a time).
        // Only when a card is face up and we couldn't play it do we
        // consider that we're done
        var keepPlaying = false
        
        repeat {
            // Always reset the keepPlaying flag; if we can, in fact,
            // keep playing, we'll set this to true somewhere below
            keepPlaying = false
            
            // There will *always* be >= 1 face-up cards in
            // each column's pile, or there will be no cards
            var pile = tableau.columns[col]
        
            // We are playing the cards in reverse order and
            // if we can play a card, great. If we can't we go on up
            // the array of face-up cards, trying to play. Cards that
            // we were not able to play on previous rounds we add to a
            // separate array so that, if we are able to move a later
            // card, then all the cards "below" it (i.e. in that array)
            // will move too
        
            // This is the array of cards that are face up but we couldn't play
            // in case a later card can, in which case they'll be moved as well
            var prevCards = [Card]()
                    
            // Now for each card in this column...
            for (i, card) in pile.fu(because: "We should always have one or more cards here").cards.enumerated().reversed() {
                var testCard = card
                // We are working with the cards in reverse order, from the bottom to the top
                // That means in a previous iteration we may have moved a card
                // away from the pile, in which case if we run across a card that
                // is face down, we want to flip it to be face up so it can be played
                if testCard == pile!.cards.last, testCard.face == .down {
                    // Flip the card up to play
                    testCard.face = .up
                    // And update the array with the fact that we flipped
                    // the card up
                    pile?.cards[i].face = .up
                    
                    // And proactively set the keepPlaying flag to false; if we
                    // are able to play it then this will be reset to true, otherwise
                    // we'll be done
                    keepPlaying = false
                }
            
                if testCard.face == .up {
                    // First let's see if we can move the card to the foundation. Remember
                    // the array is reversed, so it's like in the game we're working with the
                    // bottom-most card, which is always face-up, even if it's the only card
                    // in the column
                    var wasAbleToMove = tryToMoveToFoundation(testCard)
                    // were we able to move this card to the foundation?
                    if wasAbleToMove {
                        // yes we were! So let's remove this card from the array of cards
                        pile?.cards.remove(at: i)
                    } else {
                        // Okay, we weren't able to move it to the foundation, so let's
                        // see if we can move it to another column
                        var colMovedTo = -1
                        (wasAbleToMove, colMovedTo) = tryToMoveAroundTableau(testCard, from: col)
                        if wasAbleToMove {
                            // yes we were! So let's remove this card from the array of cards
                            pile?.cards.remove(at: i)
                        
                            // Now we check if there are any cards in the prevCards array,
                            // in which case they get to move as well
                            if prevCards.count > 0 {
                                // And try to move the other cards as well
                                for prevCard in prevCards {
                                    // Here we are simply moving the cards from one column to another
                                    move(prevCard, fromColumn: col, toColumn: colMovedTo)
                                }
                                
                                // HEY! These two lines are commented out because we are
                                // moving the card in the loop above. This stuff may not
                                // be necessary
                                
                                // let newCards = removeCards(from: pile.fu(because: "There should be cards left in the array").cards, cardsToRemove: prevCards)
                                
                                // And set the new column of cards
                                // tableau.columns[col]?.cards = newCards
                                
                                // And break out of the card loop because we need to restart with the
                                // remaining cards
                                break
                            }
                        } else {
                            // This card is face up but we were not able to move it
                            // anywhere. We add it to the prevCards array in the event
                            // that a subsequent card does move, in which case this one
                            // and any other cards in the array will move along too
                            prevCards.append(testCard)
                        }
                    }
                    
                    // If we were able to play, we should try to play again
                    if wasAbleToMove, pile!.cards.count > 0 {
                        keepPlaying = true
                    } else {
                        keepPlaying = false
                        // And get us out of the loop
                        break
                    }
                }
                
                print("Here's how it looks now in col \(col)")
                tableau.printTableau(showAllCards: true)
            }
        
            pile?.printPile("col \(col)")
            
            // And assign the current state of the pile to the column
            tableau.columns[col] = pile
        } while keepPlaying == true
    }
    
    // This function controls all the logic around playing on
    // the tableau and does not work with any of the waste cards
    mutating func playTableau() {
        // okay, let's go through each of the columns...
        for col in 0...COLUMNS {
            if isEmptyForColumn(col) {
                // Column is empty, so nothing to do
                continue
            }
            
            // Okay, what can we do with this column of cards?
            playColumn(col)
            
            // MARK: Debugging
            printCurrentCardStatsFor(self)
            tableau.printTableau(showAllCards: false)
            for (_, v) in foundations {
                v.printTopCard()
            }
        }
        
        print("Done playing the tableau")
    }
}
