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
    print("Currently have \(game.stockCount()) stock cards, \(game.totalTableauCount()) cards in tableau, and \(game.wasteCount()) in waste")
}


let game = Game()
printCurrentCardStatsFor(game)
game.play()


print("Hello, World!")

