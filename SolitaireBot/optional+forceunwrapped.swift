//
//  optional+forceunwrapped.swift
//  SolitaireBot
//
//  Created by Ron Olson on 9/27/20.
//

import Foundation

// let x = "".firstIndex(of: "D").fu(because: "There should be some text in this string")

extension Optional {
    // Force Unwrapped (i.e. using the ! on an optional)
    func fu(because assumption: String) -> Wrapped {
        guard let self = self else {
            fatalError("Whoops, found nil when unwrapping an Optional: \(assumption)")
        }
        return self
    }
}
