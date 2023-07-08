//
//  Board.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import GameplayKit

struct Board : Codable {
    var boardCards =  Array(repeating: Array(repeating: Card(), count: 10), count: 10)
    var cardStack : [Card] = []
    var allCoins : [Coin] = Coin.allCases.filter { $0.self != .special}
    init(classicView : Bool = true) {
        cardStack = [Deck(), Deck()].map { $0.cards }.reduce([], +).shuffled()
        if classicView {
            boardCards[0] = [Card(coin: .special)] + getCardsFromRankToRankSequentially(from: .six, to: .ace, of: .diamonds) + [Card(coin: .special)]
            boardCards[1] =
            [Card(rank: .five, suit: .diamonds), Card(rank: .three, suit: .hearts), Card(rank: .two, suit: .hearts)]
            + getCardsFromRankToRankSequentially(from: .two, to: .seven, of: .spades)
            + [Card(rank: .ace, suit: .clubs)]
            
            boardCards[2] =
            [Card(rank: .four, suit: .diamonds), Card(rank: .four, suit: .hearts), Card(rank: .king, suit: .diamonds), Card(rank: .ace, suit: .diamonds)]
            + getCardsFromRankToRankSequentially(from: .ten, to: .ace, of: .clubs).reversed()
            + [Card(rank: .eight, suit: .spades), Card(rank: .king, suit: .clubs)]
            
            boardCards[3] =  [Card(rank: .three, suit: .diamonds), Card(rank: .five, suit: .hearts), Card(rank: .queen, suit: .diamonds)]
            + getCardsFromRankToRankSequentially(from: .eight, to: .queen, of: .hearts).reversed()
            + [Card(rank: .nine, suit: .clubs), Card(rank: .nine, suit: .spades), Card(rank: .queen, suit: .clubs)]
            
            boardCards[4] = [Card(rank: .two, suit: .diamonds), Card(rank: .six, suit: .hearts), Card(rank: .ten, suit: .diamonds), Card(rank: .king, suit: .hearts), Card(rank: .three, suit: .hearts), Card(rank: .two, suit: .hearts), Card(rank: .seven, suit: .hearts), Card(rank: .eight, suit: .clubs), Card(rank: .ten, suit: .spades), Card(rank: .ten, suit: .clubs)]
            
            boardCards[5] =  [Card(rank: .ace, suit: .spades), Card(rank: .seven, suit: .hearts), Card(rank: .nine, suit: .diamonds), Card(rank: .ace, suit: .hearts)]
            + getCardsFromRankToRankSequentially(from: .four, to: .six, of: .hearts)
            + [Card(rank: .seven, suit: .clubs), Card(rank: .queen, suit: .spades), Card(rank: .nine, suit: .clubs)]
            
            
            boardCards[6] =  [Card(rank: .king, suit: .spades), Card(rank: .eight, suit: .hearts), Card(rank: .eight, suit: .diamonds)]
            + getCardsFromRankToRankSequentially(from: .two, to: .six, of: .clubs)
            + [Card(rank: .king, suit: .spades), Card(rank: .eight, suit: .clubs)]
            
            
            boardCards[7] =  [Card(rank: .queen, suit: .spades), Card(rank: .nine, suit: .hearts)]
            + getCardsFromRankToRankSequentially(from: .two, to: .seven, of: .diamonds).reversed()
            + [Card(rank: .ace, suit: .spades), Card(rank: .seven, suit: .clubs)]
            
            
            boardCards[8] =  [Card(rank: .ten, suit: .spades)]
            + getCardsFromRankToRankSequentially(from: .ten, to: .ace, of: .hearts)
            + getCardsFromRankToRankSequentially(from: .two, to: .six, of: .clubs)
            
            boardCards[9] = [Card(coin: .special)] + getCardsFromRankToRankSequentially(from: .two, to: .nine, of: .spades).reversed() + [Card(coin: .special)]
            
            
            
        }
        else {
            var deckOfCards = [Deck(), Deck()].map { $0.cards }.reduce([], +).shuffled()
            
            deckOfCards.removeAll { $0.rank == .jack }
            deckOfCards.insert(Card(coin: .special), at: 0)
            deckOfCards.insert(Card(coin: .special), at: 9)
            deckOfCards.insert(Card(coin: .special), at: 90)
            deckOfCards.insert(Card(coin: .special), at: 99)
            var iter = deckOfCards.makeIterator()
            boardCards = boardCards.map { $0.compactMap { _ in iter.next() }}
            
        }
    }
    
    func getCardsFromRankToRankSequentially(from :Rank, to:Rank, of suit:Suit ) -> [Card] {
        var cards : [Card] = []
        for rawValue in from.rawValue...to.rawValue {
            if rawValue != 11 {
                cards.append(Card(rank: Rank(rawValue: rawValue)!, suit: suit))
            }
        }
        return cards
    }
    
    mutating func dealCards(noOfCardsToDeal: Int) -> [Card]{
        var cards : [Card] = []
        for _ in 0...noOfCardsToDeal {
            cards.append(cardStack.removeLast())
        }
        return cards
    }
    
    mutating func uniqueCoin() -> Coin {
        if allCoins.count == 0 {
            print("SomeOne Accessed Count of Coins When 0")
            return .red
        }
        return allCoins.removeFirst()
    }
    
    
    mutating func getNumberOfSequences( index: (Int, Int)) -> Int{
        guard let coin = boardCards[index.0][index.1].coin else {
            return 0
        }
        let coordinatePairsOfFourAxis = [ [(0, -1), (0, +1)], [(-1, 0), (+1, 0)], [(-1, -1), (+1, +1)], [(-1, +1), (+1, -1)] ]
        var noOfSequences = 0
        for axis in coordinatePairsOfFourAxis {
            var sequencedIndices = getIndicesOfSameCoinsOnAAxis(from: index, axis: axis, coin: coin)
            if sequencedIndices.count >= 5 {
                if sequencedIndices.count == 10 {
                    // throw Game Over
                }
                if validateGivenSequencedIndices(sequencedIndices) {
                    sequencedIndices = reduceSequencedIndices(sequencedIndices, from: index)
                    selectSequencedCards(withIndexes: sequencedIndices )
                    noOfSequences += 1
                    // throw an alert
                }
            }
        }
        return noOfSequences
    }
    
    func reduceSequencedIndices( _ arrayOfIndexes : [(Int, Int)] , from centerIndex:(Int, Int)) -> [(Int, Int)]  {
        
        if arrayOfIndexes.count == 5 {
            return arrayOfIndexes
        }
        if let index = arrayOfIndexes.firstIndex(where: { $0 == centerIndex }) {
            if index > arrayOfIndexes.count / 2 {
                return Array(arrayOfIndexes[arrayOfIndexes.count-5..<arrayOfIndexes.count])
            }
            else {
                return Array(arrayOfIndexes[0...4])
            }
        }
        return Array(arrayOfIndexes[0...4])
    }
    
    func validateGivenSequencedIndices( _ arrayOfIndexes : [(Int, Int)] ) -> Bool{
        
        let count = arrayOfIndexes.filter { boardCards[$0.0][$0.1].belongsToASequence == true }.count
        if count > 1 {
            // throw a first time tutorial alert
            return false
        }
        
        return true
    }
    
    
    func getIndicesOfSameCoinsOnAAxis(from index: (Int, Int), axis: [(Int, Int)], coin: Coin ) -> [(Int, Int)] {
        return getIndicesOfSameCoinsOnOneSideOfAxis(from: index, axisCoordinates: axis[0], coin: coin).reversed() + [index]
        + getIndicesOfSameCoinsOnOneSideOfAxis(from: index, axisCoordinates: axis[1], coin: coin)
        
        func getIndicesOfSameCoinsOnOneSideOfAxis(from index: (Int, Int), axisCoordinates coordinates: (Int, Int), coin: Coin ) -> [(Int, Int)] {
            var indicesWithSameCoins : [(Int, Int)] = []
            for i in 1..<5 {
                let x = index.0 + i * coordinates.0
                let y = index.1 + i * coordinates.1
                if isIndexValid(x: x, y: y) {
                    if boardCards[x][y].coin == coin || boardCards[x][y].coin == .special {
                        indicesWithSameCoins.append((x, y))
                    } else { break }
                } else { break }
            }
            return indicesWithSameCoins
        }
    }
    
    
    
    mutating func selectSequencedCards(withIndexes sequencedIndexes : [(Int, Int)]) {
        for index in sequencedIndexes {
            if boardCards[index.0][index.1].suit != nil  {
                boardCards[index.0][index.1].belongsToASequence = true
            }
        }
    }
    
    func isIndexValid(x : Int, y : Int) -> Bool {
        boardCards.indices.contains(x) && boardCards.first!.indices.contains(y)
    }
    
}


extension Array where Element : Collection,
                      Element.Iterator.Element : Equatable, Element.Index == Int {
    func indicesOf(x: Element.Iterator.Element) -> (Int, Int)? {
        for (i, row) in self.enumerated() {
            if let j = row.firstIndex(of: x) {
                return (i, j)
            }
        }
        
        return nil
    }
}
