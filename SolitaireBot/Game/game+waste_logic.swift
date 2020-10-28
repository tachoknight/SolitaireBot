//
//  game+waste_logic.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/22/20.
//

import Foundation

extension Game {
    mutating func moveWasteToStock() {
        print("Moving from waste to stock")
        // Move the cards from the waste to the
        // stock as a copy, setting all the
        // faces to down
        for card in self.waste.cards {
            var fdCard = card
            fdCard.face = .down
            self.stock.cards.append(fdCard)
        }

        // And get rid of the cards in the waste
        self.waste.cards.removeAll()
    }
}
