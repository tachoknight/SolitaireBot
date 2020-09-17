//
//  main.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/17/20.
//

import Foundation

// Make sure we have some better random numbers
#if os(Linux)
    srand(UInt32(time(nil)))
#endif

// Create our deck of cards
var deck = createDeck()

// From the MutableCollectionType extension
#if DEBUG
    print("Now shuffling the deck...")
#endif

var shuffleLoop = 1
repeat {
    deck.myShuffle()
    shuffleLoop += 1
} while shuffleLoop < 1000

#if DEBUG
    for card in deck {
        print(card)
    }
#endif


print("Hello, World!")

