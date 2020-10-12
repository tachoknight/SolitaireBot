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

    // This is the serial number of the game, basically the hash
    // of the deck after it's been shuffled, so we can keep track
    // of what games have been played
    var serialNum: Int = 0

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

    // A record of the moves that were made during the game
    var moves =  [Move]()
    // Our current move counter
    var moveNum = 0
    
    public init() {
        print("Setting up the game")
        // Because we're in the default initializer,
        // we want a new deck of cards
        createNewDeck()
        // And shuffle it
        shuffleNewDeck()
        // And get the game's serial number
        setSerialNumber()
        // And now let's set up the tableau
        setupTableau()
        // And initialize our foundations
        setupFoundations()
        // And now the remaining cards get sent to the stock
        self.stock.cards = self.deck!
        self.stock.printPile("stock")
    }
}

// MARK: - Setup
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
                print("Our deck...")
                for card in cardDeck {
                    print(card)
                }
            }
        #endif
    }

    mutating func setSerialNumber() {
        var deckLayout = ""
        if let cardDeck = self.deck {
            for card in cardDeck {
                deckLayout += card.description
            }
        }
        self.serialNum = deckLayout.hash
        print("Hash value is \(deckLayout.hash)")
    }

    mutating func setupTableau() {
        self.tableau.newWith(&self.deck!)
    }
    
    mutating func setupFoundations() {
        // iterating over the enum is possible because it
        // conforms to the CaseIterable protocol
        for s in Suit.allCases {
            var f = Foundation(suit: s)
            // When we're creating a new foundation, we add as the bottom
            // card the null card. The reason for this is for making comparisons
            // of what is on the pile to a test card easier; a null card has a
            // value of 0, while the ace has a value of 1. That means that we
            // can always simply subtract the test card from the top card and
            // if we get 1, we know that test card can be put on the pile without
            // special "ace" logic that checks if the cards array is empty and
            // the test card is an ace.
            f.pile.cards.append(Card(rank: .null, suit: s, face: .noface))
            self.foundations[s] = f
        }
    }
}

// MARK: - Counts
extension Game {
    func wasteCount() -> Int {
        return self.waste.cards.count
    }
    
    func stockCount() -> Int {
        return self.stock.cards.count
    }
    
    func totalTableauCount() -> Int {
        return self.tableau.totalCardCount()
    }
    
    func totalFoundationCount() -> Int {
        var count = 0
        for s in Suit.allCases {
            count += foundationCountFor(s)
        }
        
        return count
    }
    
    func foundationCountFor(_ suit: Suit) -> Int {
        return self.foundations[suit]?.count().1 ?? 0
    }
}
