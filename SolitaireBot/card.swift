
import Foundation

let NUM_OF_CARDS_IN_DECK = 52

// MARK: - Face

enum Face: Int {
    case up = 0
    case down = 1
    case noface = 2

    func simpleDescription() -> String {
        switch self {
        case .up:
            return "face up"
        case .down:
            return "face down"
        case .noface:
            return "no face"
        }
    }

    func face() -> String {
        switch self {
        case .up:
            return "up"
        case .down:
            return "down"
        case .noface:
            return "no face"
        }
    }
}

// MARK: - Card Color

enum CardColor: Int {
    case red = 0
    case black = 1
    case none = 2
}

// MARK: - Suit

enum Suit: Int, CaseIterable {
    case hearts = 100
    case spades = 200
    case diamonds = 300
    case clubs = 400
    case noSuit = 0

    func simpleDescription() -> String {
        switch self {
        case .spades:
            return "spades"
        case .hearts:
            return "hearts"
        case .diamonds:
            return "diamonds"
        case .clubs:
            return "clubs"
        case .noSuit:
            return "no suit"
        }
    }

    func color() -> CardColor {
        switch self {
        case .spades:
            return .black
        case .clubs:
            return .black
        case .diamonds:
            return .red
        case .hearts:
            return .red
        case .noSuit:
            return .none
        }
    }

    func symbol() -> String {
        switch self {
        case .spades:
            return "♠"
        case .clubs:
            return "♣"
        case .diamonds:
            return "♦"
        case .hearts:
            return "♥"
        case .noSuit:
            return "NS"
        }
    }
}

func convertSymbolToSuit(_ symbol: String) -> Suit {
    switch symbol {
    case "♠":
        return .spades
    case "♣":
        return .clubs
    case "♦":
        return .diamonds
    case "♥":
        return .hearts
    default:
        return .noSuit
    }
}

// MARK: - Rank

enum Rank: Int {
    case null = 0
    case ace = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king

    func simpleDescription() -> String {
        switch self {
        case .ace:
            return "ace"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        default:
            return String(rawValue)
        }
    }

    func symbol() -> String {
        switch self {
        case .ace:
            return "A"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        default:
            return String(rawValue)
        }
    }

    // This allows us to find the difference between two
    // ranks of two different cards.
    static func - (_ x: Rank, _ y: Rank) -> Int {
        return x.rawValue - y.rawValue
    }
}

func convertSymbolToRank(_ symbol: String) -> Rank {
    switch symbol {
    case "A":
        return .ace
    case "2":
        return .two
    case "3":
        return .three
    case "4":
        return .four
    case "5":
        return .five
    case "6":
        return .six
    case "7":
        return .seven
    case "8":
        return .eight
    case "9":
        return .nine
    case "10":
        return .ten
    case "J":
        return .jack
    case "Q":
        return .queen
    case "K":
        return .king
    default:
        return .null
    }
}

//

// MARK: - Card

// The card struct/class that is what we're playing
// with
//
struct Card: Hashable, CustomStringConvertible {
    var rank: Rank
    var suit: Suit
    var face: Face

    init(rank: Rank, suit: Suit, face: Face) {
        self.rank = rank
        self.suit = suit
        self.face = face
    }

    // We are given a string like 10♠ and we want
    // to translate that into a valid card value
    init(desc: String) {
        let suitSymbol = String(desc.last!)
        let rankSymbol = String(desc.prefix(desc.count - 1))

        self.face = .down
        self.suit = convertSymbolToSuit(suitSymbol)
        self.rank = convertSymbolToRank(rankSymbol)
    }

    // For storing in dictionaries
    func hash(into hasher: inout Hasher) {
        hasher.combine(rank.rawValue + suit.rawValue)
    }

    func simpleDescription() -> String {
        if isNullCard() {
            return "Null Card"
        }

        return "The \(rank.simpleDescription()) of \(suit.simpleDescription())"
    }

    func fullDescription(shouldShowFace: Bool) -> String {
        if isNullCard() {
            return " "
        } else if shouldShowFace == false, face == .down {
            return "X"
        } else {
            return description
        }
    }

    // From CustomStringConvertable protocol
    var description: String {
        if isNullCard() {
            return "N"
        }

        return "\(rank.symbol())\(suit.symbol())"
    }
}

// A Null card is basically a placeholder for where a card
// could be, but isn't
extension Card {
    func isNullCard() -> Bool {
        return rank == .null
    }
}

// For the Card class' equatable protocol
func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: - Card functions

//
// Function for creating a deck of cards
//
func createDeck() -> [Card] {
    var n = 1
    var deck = [Card]()
    while let rank = Rank(rawValue: n) {
        var m = 100
        while let suit = Suit(rawValue: m) {
            // By default all the cards are assembled face down
            deck.append(Card(rank: rank, suit: suit, face: Face.down))
            m += 100
        }
        n += 1
    }
    return deck
}

// We load a file that contains the cards in the order
// we need. It would be pointless to shuffle the results
// of this function as presumably they're in order for a
// reason :)
func createDeck(fileContents: String) -> [Card] {
    var deck = [Card]()
    let cardArray = fileContents.components(separatedBy: "\n")
    for cardString in cardArray {
        deck.append(Card(desc: cardString))
    }

    return deck
}

// MARK: - Extensions for card

#if os(Linux)
    extension MutableCollection where Index == Int {
        /// Shuffle the elements of `self` in-place.
        mutating func myShuffle() {
            // empty and single-element collections don't shuffle
            if count < 2 { return }

            for i in startIndex ..< endIndex - 1 {
                let j = Int(random() % (endIndex - i)) + i
                guard i != j else { continue }
                swapAt(i, j)
            }
        }
    }
#else
    extension MutableCollection where Index == Int {
        /// Shuffle the elements of `self` in-place.
        mutating func myShuffle() {
            // empty and single-element collections don't shuffle
            if count < 2 { return }

            for i in startIndex ..< endIndex - 1 {
                let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
                guard i != j else { continue }
                swapAt(i, j)
            }
        }
    }
#endif
