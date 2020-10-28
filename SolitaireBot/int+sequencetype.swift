//
//  int+sequencetype.swift
//  SolitaireBot
//
//  Created by Ron Olson on 10/28/20.
//

import Foundation

// So ints can be used in sequences
extension Int: Sequence {
    public func makeIterator() -> CountableRange<Int>.Iterator {
        return (0..<self).makeIterator()
    }
}
