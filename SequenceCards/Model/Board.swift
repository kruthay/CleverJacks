//
//  Board.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import GameplayKit

struct Board : Codable, CustomStringConvertible {
    var description: String {
        return "allCoins: \(allCoins), countOfCardStack : \(cardStack.count)"
    }
    
    var id = UUID()    
    var boardCards =  Array(repeating: Array(repeating: Card(), count: 10), count: 10)
    var cardStack : [Card] = []
    var allCoins : [Coin] = Coin.allCases.filter { $0.self != .special}
    let numberOfPlayers: Int
    let requiredNoOfSequences: Int
    var aboutToBeSequence: [Coin : [Int]] = [:]
    
    init(tutorial: Bool = true ) {
        self.numberOfPlayers = 2
        let decks = [Deck(), Deck()]
        
        self.cardStack = decks.map { $0.cards }.reduce([], +).shuffled()
        
        let firstPersonCards = [Card(rank: .nine, suit: .spades ) , Card(rank: .queen , suit:.hearts) , Card(rank: .six, suit: .diamonds), Card(rank: .three, suit: .clubs) , Card(rank: .five, suit: .hearts)].shuffled()
        for card in firstPersonCards {
            cardStack.removeAll {
                $0.hasASameFaceAs(card)
            }
        }
        
        
        
        self.requiredNoOfSequences = 2
        self.boardCards = createAClassicBoard()
    }
    
    
    init(classicView : Bool = true, numberOfPlayers : Int) {
        self.numberOfPlayers = numberOfPlayers
        let decks = [Deck(), Deck()]
        cardStack = decks.map { $0.cards }.reduce([], +).shuffled()
        if numberOfPlayers % 3 == 0 {
            requiredNoOfSequences = 1
        }
        else {
            requiredNoOfSequences = 2
        }

        if classicView {
            boardCards = createAClassicBoard()
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
    
    func cardsWithCoinsCount() -> Int {
        return boardCards.joined().filter { $0.coin != nil }.count
    }
    
    func numberOfSelectableCardsLeftInTheBoard(_ card: Card) -> Int {
        return boardCards.joined().filter { $0.hasASameFaceAs(card) && $0.coin == nil }.count
    }
    
    
    mutating func dealCards(noOfCardsToDeal: Int) -> [Card]{
        var dealtCards : [Card] = []
        for _ in 0...noOfCardsToDeal {
            print("CardStacksCount in deakCards \(cardStack.count)")
            if let card = cardStack.popLast() {
                dealtCards.append(card)
            } else {
                print("CardStack shouldn't be empty")
            }
        }
        return dealtCards
    }
    
    mutating func uniqueCoin() -> Coin {
        if allCoins.count == 0 {
            print("SomeOne Accessed Count of Coins When 0")
            return .special
        }
        return allCoins.removeFirst()
    }
    
    

    
    // Finds the Number of Sequences from the given index
    mutating func getNumberOfSequences( index: (Int, Int)) -> Int{
        // For Some reason, if coin is empty, no sequence
        guard let coin = boardCards[index.0][index.1].coin else {
            // Shouldn't be empty
            print("Empty Card Selected, Index: \(index), card: \(boardCards[index.0][index.1])")
            return 0
        }
        let coordinatePairsOfFourAxis = [ [(0, -1), (0, +1)], [(-1, 0), (+1, 0)], [(-1, -1), (+1, +1)], [(-1, +1), (+1, -1)] ]
        var noOfSequences = 0
        
        for axis in coordinatePairsOfFourAxis {
            var sequencedIndices = getIndicesOfSameCoinsOnAAxis(from: index, axis: axis, coin: coin)
            
            if sequencedIndices.count >= 5 {
                if sequencedIndices.count == 10 {
                    // throw Game Over
                    noOfSequences  = 2
                    return 2
                }
               else if validateGivenSequencedIndices(sequencedIndices) {
                    sequencedIndices = selectImportantIndices(sequencedIndices, from: index)
                    selectSequencedCards(withIndexes: sequencedIndices )
                    noOfSequences += 1
                    // throw an alert
                }
            }
            else if sequencedIndices.count == 4 && noOfSequences == 0 && coin == .blue{
                aboutToBeSequence[coin] = [sequencedIndices.randomElement()!.0, sequencedIndices.randomElement()!.1]
                print(aboutToBeSequence)
            }
        }
        return noOfSequences
    }
    
    /// Selecting only 5 indices to finish a sequence, needs a rewrite
    ///  Responsible for prioritising cards on the edges.
    func selectImportantIndices( _ arrayOfIndexes : [(Int, Int)] , from selectedCardIndex:(Int, Int)) -> [(Int, Int)]  {
        if arrayOfIndexes.count == 5 {
            return arrayOfIndexes
        }
        if let specialCoinIndex = arrayOfIndexes.firstIndex(where: { boardCards[$0.0][$0.1].coin == .special }) {
            if specialCoinIndex > arrayOfIndexes.count / 2 {
                return Array(arrayOfIndexes[arrayOfIndexes.count-5..<arrayOfIndexes.count])
            }
            else {
                return Array(arrayOfIndexes[0...4])
            }
        }
        if let index = arrayOfIndexes.firstIndex(where: { $0 == selectedCardIndex }) {
            if index > arrayOfIndexes.count / 2 {
                return Array(arrayOfIndexes[arrayOfIndexes.count-5..<arrayOfIndexes.count])
            }
            else {
                return Array(arrayOfIndexes[0...4])
            }
        }
        return Array(arrayOfIndexes[0...4])
    }
    
    // if two coins from an already completed sequence are selected then it's not valid
    func validateGivenSequencedIndices( _ arrayOfIndexes : [(Int, Int)] ) -> Bool{
        
        let count = arrayOfIndexes.filter { boardCards[$0.0][$0.1].belongsToASequence == true }.count
        if count > 1 {
            // throw a first time tutorial alert
            return false
        }
        
        return true
    }
    
    
    // Indices of sequential coins from an index with a coin, on a axis
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
    
    
    
    mutating func getScoreForTheGivenIndexAndCoin(index: (Int, Int), coin: Coin) -> Int {
        var score = 0
        let coordinatePairsOfFourAxis = [ [(0, -1), (0, +1)], [(-1, 0), (+1, 0)], [(-1, -1), (+1, +1)], [(-1, +1), (+1, -1)] ]
        for axis in coordinatePairsOfFourAxis {
            score += getScoresOfSameCoinsOnAAxis(from: index, axis: axis, coin: coin)
            
        }
        return score
    }
    
    
    
    // Scores of sequential coins from an index with a coin, on a axis
    mutating func getScoresOfSameCoinsOnAAxis(from index: (Int, Int), axis: [(Int, Int)], coin: Coin ) -> Int {
        return getScoresOfSameCoinsOnOneSideOfAxis(from: index, axisCoordinates: axis[0], coin: coin)
        + getScoresOfSameCoinsOnOneSideOfAxis(from: index, axisCoordinates: axis[1], coin: coin)
        
        func getScoresOfSameCoinsOnOneSideOfAxis(from index: (Int, Int), axisCoordinates coordinates: (Int, Int), coin: Coin ) -> Int {
            var score : Int = 0
            for i in 1..<5 {
                let x = index.0 + i * coordinates.0
                let y = index.1 + i * coordinates.1
                if isIndexValid(x: x, y: y) {
                    if boardCards[x][y].coin == coin || boardCards[x][y].coin == .special {
                        score += 1
                    } else if boardCards[x][y].coin == .none {
                        score += 0
                        if score >= 3 {
                            aboutToBeSequence[Coin.green] = [x, y]
                        }
                    }
                    else { break }
                } else { break }
            }
            return score
        }
    }
    
    func isIndexValid(x : Int, y : Int) -> Bool {
        boardCards.indices.contains(x) && boardCards.first!.indices.contains(y)
    }
    
    
    // Should be in a utility space
    func getCardsFromRankToRankSequentially(from :Rank, to:Rank, of suit:Suit ) -> [Card] {
        var cards : [Card] = []
        for rawValue in from.rawValue...to.rawValue {
            if rawValue != 11 {
                cards.append(Card(rank: Rank(rawValue: rawValue)!, suit: suit))
            }
        }
        return cards
    }
    
    func createAClassicBoard() -> [[Card]] {
        var classicBoard = Array(repeating: Array(repeating: Card(), count: 10), count: 10)
        classicBoard[0] = [Card(coin: .special)] + getCardsFromRankToRankSequentially(from: .six, to: .ace, of: .diamonds) + [Card(coin: .special)]
        classicBoard[1] =
        [Card(rank: .five, suit: .diamonds), Card(rank: .three, suit: .hearts), Card(rank: .two, suit: .hearts)]
        + getCardsFromRankToRankSequentially(from: .two, to: .seven, of: .spades)
        + [Card(rank: .ace, suit: .clubs)]
        
        classicBoard[2] =
        [Card(rank: .four, suit: .diamonds), Card(rank: .four, suit: .hearts), Card(rank: .king, suit: .diamonds), Card(rank: .ace, suit: .diamonds)]
        + getCardsFromRankToRankSequentially(from: .ten, to: .ace, of: .clubs).reversed()
        + [Card(rank: .eight, suit: .spades), Card(rank: .king, suit: .clubs)]
        
        classicBoard[3] =  [Card(rank: .three, suit: .diamonds), Card(rank: .five, suit: .hearts), Card(rank: .queen, suit: .diamonds)]
        + getCardsFromRankToRankSequentially(from: .eight, to: .queen, of: .hearts).reversed()
        + [Card(rank: .nine, suit: .clubs), Card(rank: .nine, suit: .spades), Card(rank: .queen, suit: .clubs)]
        
        classicBoard[4] = [Card(rank: .two, suit: .diamonds), Card(rank: .six, suit: .hearts), Card(rank: .ten, suit: .diamonds), Card(rank: .king, suit: .hearts), Card(rank: .three, suit: .hearts), Card(rank: .two, suit: .hearts), Card(rank: .seven, suit: .hearts), Card(rank: .eight, suit: .clubs), Card(rank: .ten, suit: .spades), Card(rank: .ten, suit: .clubs)]
        
        classicBoard[5] =  [Card(rank: .ace, suit: .spades), Card(rank: .seven, suit: .hearts), Card(rank: .nine, suit: .diamonds), Card(rank: .ace, suit: .hearts)]
        + getCardsFromRankToRankSequentially(from: .four, to: .six, of: .hearts)
        + [Card(rank: .seven, suit: .clubs), Card(rank: .queen, suit: .spades), Card(rank: .nine, suit: .clubs)]
        
        
        classicBoard[6] =  [Card(rank: .king, suit: .spades), Card(rank: .eight, suit: .hearts), Card(rank: .eight, suit: .diamonds)]
        + getCardsFromRankToRankSequentially(from: .two, to: .six, of: .clubs)
        + [Card(rank: .king, suit: .spades), Card(rank: .eight, suit: .clubs)]
        
        
        classicBoard[7] =  [Card(rank: .queen, suit: .spades), Card(rank: .nine, suit: .hearts)]
        + getCardsFromRankToRankSequentially(from: .two, to: .seven, of: .diamonds).reversed()
        + [Card(rank: .ace, suit: .spades), Card(rank: .seven, suit: .clubs)]
        
        
        classicBoard[8] =  [Card(rank: .ten, suit: .spades)]
        + getCardsFromRankToRankSequentially(from: .ten, to: .ace, of: .hearts)
        + getCardsFromRankToRankSequentially(from: .two, to: .six, of: .clubs)
        
        classicBoard[9] = [Card(coin: .special)] + getCardsFromRankToRankSequentially(from: .two, to: .nine, of: .spades).reversed() + [Card(coin: .special)]
        
        return classicBoard
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
