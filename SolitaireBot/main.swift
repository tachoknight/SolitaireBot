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

let game = Game()


print("Hello, World!")

