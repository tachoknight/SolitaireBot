//
//  game.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/17/20.
//

import Foundation

// The Game is comprised of all the various piles and a deck of
// cards
struct Game {
    // This is the deck of cards we're going to be playing with. Note
    // that it is not initialized because we may be creating a new
    // deck for a new game, or passing in an existing deck for
    // further analysis
    var deck: [Card]?

    // The waste pile is where the cards go that cannot be
    // played on any of the tableau piles
    var waste = Pile()

    // The stock pile is where the cards are dealt from
    var stock = Pile()

    // The tableau is where the game is played, essentially; it
    // is here that cards are moved around, from column to column,
    // trying to allow for more cards to come off the stock and
    // ultimately go to the Foundations
    var tableau = Tableau()

    // The ultimate destination of the cards from the tableau or
    // the stock.
    var foundations = [Suit: Foundation]()

    init() {
        print("Setting up the game")
        // Because we're in the default initializer,
        // we want a new deck of cards
        createNewDeck()
        // And shuffle it
        shuffleNewDeck()
        // And now let's set up the tableau
        setupTableau()
    }
}

extension Game {
    mutating func createNewDeck() {
        self.deck = createDeck()
    }

    mutating func shuffleNewDeck() {
        // From the MutableCollectionType extension
        #if DEBUG
            print("Now shuffling the deck...")
        #endif

        var shuffleLoop = 1
        repeat {
            self.deck?.myShuffle()
            shuffleLoop += 1
        } while shuffleLoop < 1000

        #if DEBUG
            if let cardDeck = self.deck {
                for card in cardDeck {
                    print(card)
                }
            }
        #endif
    }

    mutating func setupTableau() {
        if var cardDeck = self.deck {
            self.tableau.resetWith(&cardDeck)
        }
    }
}
