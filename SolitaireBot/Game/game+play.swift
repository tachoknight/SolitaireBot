//
//  game+play.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/3/20.
//

import Foundation

// This file contains the code for actually playing the game; how the "user"
// would interact with it. The functions in this file call the functions in
// game+logic.swift to figure out what card is playable where, etc.

// MARK: - Gameplay

extension Game {
    // Play a game of solitaire
    mutating func play() {
        var gameDone = false
        
        // Okay, here's our main loop. Once we break out
        // of this loop the game is done, regardless of whether
        // we won or not
        repeat {
            let previousMoveNum = self.moveNum
            print("=== Currently on move \(self.moveNum + 1) ===")
            
            // First thing we do is check for anything on the
            // tableau that's playable
            playTableau()
            // Okay, we can't do anything more with the tableau,
            // so let's move on to the stock
            playFromWaste()
            
            // MARK: Debugging
            printCurrentCardStatsFor(self)
            tableau.printTableau(showAllCards: false)
            for (_, v) in foundations {
                v.printTopCard()
            }
            waste.printPile("waste after")
            print("=== round over ===")
            
            // Is the game over?
            // If no moves were made on this round, the
            // game is over
            if previousMoveNum == self.moveNum {
                print("No moves were made!")
                gameDone = true
            }
            
        } while gameDone == false
        
        print("Game was over in \(self.moveNum + 1) moves")
        
    }
}
