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
        var cardsBeingMoved = [Card]()
        var foundCard = false
        var rowPosition = 0
        for card in tableau.columns[from].fu(because: "There should be a card in this column to move").cards {
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
    mutating func tryToMoveAroundTableau(_ cards: [Card], from: Int) -> Bool {
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
    
    func tryToMoveToFoundation(_ cards: inout [Card], from: Int) -> Bool {
        var successfullyMovedToFoundation = false
        
        var removedCards = [Card]()
        
        for testCard in cards {
            // Get the pile of cards for this foundation
            // Note the pile may be empty
            var foundationPile = self.foundations[testCard.suit]?.pile
            
            // First let's get the top-most card (i.e. last) from the
            // foundation pile...
            let topFoundationCard = foundationPile?.cards.last
            
            // ... and now we compare it to the test card. We have a
            // static subtraction operator in the Rank enum so we
            // can perform a simple subtraction. The only way our
            // test card gets put onto the foundation pile is if
            // it is one greater than the current top foundation card
            // (e.g. 2 is greater than ace, but 7 is not one greater
            // than 5, etc.)
            if testCard.rank - topFoundationCard!.rank != 1 {
                // We can't play this card on the foundation
                continue
            } else {
                // Oh, nice, we can put this card on the foundation
                foundationPile?.cards.append(testCard)
                // And add it to our array of cards to remove when
                // we're done (we don't remove it here via enumeration
                // because we don't want to have to deal with a reversed
                // array and all the more complex logic that would entail)
                removedCards.append(testCard)
                // And tell the caller we were succesful
                successfullyMovedToFoundation = true
            }
        }
        
        // Now we want to remove the cards we were able to move to
        // the foundation from the array that we were passed
        cards = removeCards(from: cards, cardsToRemove: removedCards)
        
        return successfullyMovedToFoundation
    }
    
    mutating func playColumn(_ col: Int) {
        // There will *always* be >= 1 face-up cards in
        // each column's pile, or there will be no cards
        let pile = tableau.columns[col]
        
        // Now for each card in this column...
        for (i, card) in pile.fu(because: "We should always have one or more cards here").cards.enumerated().reversed() {
            // We only want to work with face up cards
            if card.face == .up {
                
            }
        }
        
        var fuCards = getFaceUpCards(pile.fu(because: "There should be cards in this pile"))
        // Can any of these cards be moved to foundations?
        let wasAbleToMoveToFoundation = tryToMoveToFoundation(&fuCards, from: col)
        
        // Any remaining cards in the fuCards array we now try to move to
        // other places on the tableau
        var wasAbleToPlay = tryToMoveAroundTableau(fuCards, from: col)
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
        }
    }
}
