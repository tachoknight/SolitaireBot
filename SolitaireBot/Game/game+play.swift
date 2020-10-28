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
            // First thing we do is check for anything on the
            // tableau that's playable
            playTableau()
            // Okay, we can't do anything more with the tableau,
            // so let's move on to the stock
            playFromWaste()
        } while gameDone == false
    }
}
