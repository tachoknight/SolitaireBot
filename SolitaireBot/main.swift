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


var game = Game()
printCurrentCardStatsFor(game)
game.play()


print("Hello, World!")

