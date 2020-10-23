//
//  move.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/24/20.
//

import Foundation


// A move is a record of a card being played, the
// card itself and where it came from and where it went
// to, on what turn
// Note that the card is actually an array of cards. We may
// have moved a card that had cards below it, in which case we
// want to document that all the cards moved; the first element
// of the array is the card that was played (and there may be only
// one card in the array), and all subsequent cards, if any, were
// the cards below it
struct Move {
    // timestamp of when move occured
    let ts = Date()
    var turn = 0
    var cards: [Card]
    var from = ""
    var to = ""
    
    public init(turn: Int, cards: [Card], from: String, to: String) {
        self.turn = turn
        self.cards = cards
        self.from = from
        self.to = to
    }
    
    // Similar but only one card
    public init(turn: Int, card: Card, from: String, to: String) {
        self.turn = turn
        self.cards = [Card]()
        self.cards.append(card)
        self.from = from
        self.to = to
    }
}
