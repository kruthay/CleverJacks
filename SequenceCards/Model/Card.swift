//
//  Card.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

struct Card : Identifiable, Equatable, Hashable, CustomStringConvertible, Codable {
    let rank: Rank?
    
    let suit: Suit?
    
    var id = UUID()
    
    var coin: Coin? = nil
    
    var belongsToASequence = false
    
    var description: String {
        return ("\(rank?.symbol ?? "No Rank") : \(suit?.symbol ?? "No Suit")")
    }
    
    var isASpecialCard : Bool { rank == .jack }
    
    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
    
    init(){
        self.rank = nil
        self.suit = nil
        self.coin = nil
    }
    init(coin : Coin){
        self.rank = nil
        self.suit = nil
        self.coin = coin
    }
}
