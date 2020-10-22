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

func printCurrentCardStatsFor(_ game: Game) {
    print("Currently have \(game.stockCount()) stock cards, \(game.totalTableauCount()) cards in tableau, \(game.totalFoundationCount()) in foundations, and \(game.wasteCount()) in waste")
}

func maybeUseDeckFile() -> (Bool, String) {
    guard let deckFile = UserDefaults.standard.string(forKey: "deckfile") else {
        return (false, "")
    }

    return (true, deckFile)
}

// Our actual game that we're going to use
var game: Game

let deckCheck = maybeUseDeckFile()
if deckCheck.0 == false {
    // Regular game with a new and shuffled deck
    game = Game()
} else {
    // Let's see about getting the contents of this file
    // then
    print("Going to use the deck from \(deckCheck.1)")
    let url = URL(fileURLWithPath: deckCheck.1)
    let deckFileContents = try String(contentsOf: url, encoding: .utf8)
    game = Game(deckFileContents)
}

printCurrentCardStatsFor(game)
game.play()


print("Hello, World!")

