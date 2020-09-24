//
//  move.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/24/20.
//

import Foundation

// Crude but refactor as we get more into it
enum BoardPart: Int {
    case waste = 0
    case stock = 1
    
    case tableau0 = 10
    case tableau1 = 11
    case tableau2 = 12
    case tableau3 = 13
    case tableau4 = 14
    case tableau5 = 15
    case tableau6 = 16
    
    case foundation_hearts = 20
    case foundation_spades = 21
    case foundation_diamonds = 22
    case foundation_clubs = 23
}

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
    var from: BoardPart
    var to: BoardPart
    
    public init(turn: Int, cards: [Card], from: BoardPart, to: BoardPart) {
        self.turn = turn
        self.cards = cards
        self.from = from
        self.to = to
    }
}
