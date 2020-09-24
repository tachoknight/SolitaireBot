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
    func play() {
        //for
    }
}
