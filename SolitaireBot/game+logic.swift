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
    // Play a game of solitaire
    mutating func play() {
        var gameDone = false
        
        // Okay, here's our main loop. Once we break out
        // of this loop the game is done, regardless of whether
        // we won or not
        repeat {
            // First thing we do is check for anything on the
            // tableau that's playable
            playTableau()
        } while gameDone == false
    }
    
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
        var cardsBeingMoved = [Card]()
        var foundCard = false
        var rowPosition = 0
        for card in tableau.columns[from]!.cards {
            // Loop through the pile looking for the card we're going to move...
            if card == cardToMove {
                // ... which we found ...
                foundCard = true
            }
            
            // ... and from here on out we're going to move every card
            // from the pile in the from column to the pile in the to
            // column
            if foundCard {
                // Remove the card from the From column
                let cardToMove = tableau.columns[from]!.cards.remove(at: rowPosition)
                // And add it to the To column
                tableau.columns[to]!.cards.append(cardToMove)
                // And also add it to our cardsBeingMoved array for documenting it
                cardsBeingMoved.append(cardToMove)
            }
            
            rowPosition += 1
        }
        
        // We moved one or more cards, so let's add a Move record to indicate that
        self.moveNum += 1
        let move = Move(turn: moveNum, cards: cardsBeingMoved, from: "Col" + String(from), to: "Col" + String(to))
        moves.append(move)
    }
    
    // This function is responsible for taking an array of cards
    // and the originating column and looking at the other columns'
    // bottom card and see if it's playable
    mutating func tryToPlay(_ cards: [Card], from: Int) -> Bool {
        // We want to move as many cards as possible in a turn, so
        // we start at the top of the array because if we can match
        // a card early, then all the other cards in the array will
        // come along for the ride, woo.
        for testCard in cards {
            // So now let's go through the columns other than the one
            // we came from
            for col in 0...COLUMNS {
                if col == from {
                    // skip the column we came from
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
                    return true
                }
            }
        }
        
        return false
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
            // There will *always* be >= 1 face-up cards in
            // each column's pile, or there will be no cards
            let pile = tableau.columns[col]
            let fuCards = getFaceUpCards(pile!)
            var wasAbleToPlay = tryToPlay(fuCards, from: col)
        }
    }
}
