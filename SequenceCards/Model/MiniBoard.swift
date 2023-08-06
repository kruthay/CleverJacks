//
//  MiniBoard.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 8/5/23.
//

import Foundation

enum Direction : String {
    case horizontal = "Horizontally"
    case vertical = "Vertically"
    case diagonal = "Diagonally"
    
    
}
struct MiniBoard : Hashable, Identifiable {
    var id = UUID()
    var numberOfAnimations = 0
    var direction: Direction
    var miniBoardCards : [[Card]]
    var allValuesUpdated = false
    init(direction: Direction) {
        self.direction = direction
        self.miniBoardCards = resetBoardCards
    }
    
    let resetBoardCards = [
        [Card(coin: .special), Card(rank:.six, suit: .diamonds), Card(rank:.seven, suit: .diamonds), Card(rank:.eight, suit: .diamonds), Card(rank:.nine, suit: .diamonds)],
        
        [Card(rank:.five, suit: .diamonds),Card(rank:.three, suit: .hearts), Card(rank:.two, suit: .hearts), Card(rank:.two, suit: .spades), Card(rank:.three, suit: .spades)],
        
        [Card(rank:.four, suit: .diamonds), Card(rank:.four, suit: .hearts), Card(rank:.king, suit: .diamonds), Card(rank:.ace, suit: .diamonds), Card(rank:.ace, suit: .clubs)],
        
        
        [Card(rank:.three, suit: .diamonds), Card(rank:.five, suit: .hearts), Card(rank:.queen, suit: .diamonds), Card(rank:.queen, suit: .hearts), Card(rank:.ten, suit: .hearts)],
        
        [Card(rank:.two, suit: .diamonds), Card(rank:.six, suit: .hearts), Card(rank:.ten, suit: .diamonds), Card(rank:.king, suit: .hearts), Card(rank:.three, suit: .hearts)]
    ]
    
    

    mutating func update() {
        
        switch(direction) {
        case .horizontal:
            if let index = miniBoardCards[2].firstIndex(where: { $0.coin == nil } ) {
                self.miniBoardCards[2][index].coin = .blue
            }
            else {
                makeSequence()
            }
        case .vertical:
            if let index = miniBoardCards.firstIndex(where: { $0[2].coin == nil } ) {
                self.miniBoardCards[index][2].coin = .blue
            }
            else {
                makeSequence()
            }

        case .diagonal:
            if let index = miniBoardCards.indices.firstIndex(where: { miniBoardCards[$0][$0].coin == nil })  {
                self.miniBoardCards[index][index].coin = .blue
            }
            else {
                makeSequence()
            }
        }
        
        
    }
    mutating func reset() {
        
        miniBoardCards = resetBoardCards
        
        allValuesUpdated.toggle()
        
    }
    
    
    mutating func makeSequence() {
        numberOfAnimations += 1
        allValuesUpdated.toggle()
        switch(direction) {
        case .horizontal:
            for index in 0..<miniBoardCards.count {
                self.miniBoardCards[2][index].belongsToASequence = true
            }
        case .vertical:
            for index in 0..<miniBoardCards.count {
                self.miniBoardCards[index][2].belongsToASequence = true
            }

        case .diagonal:
            for index in 1..<miniBoardCards.count {
                self.miniBoardCards[index][index].belongsToASequence = true
            }
        }
        
    }
    
}

