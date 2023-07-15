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
    
    var coin: Coin?
    
    var belongsToASequence = false
    
    var description: String {
        return ("\(rank?.symbol ?? "No Rank") : \(suit?.symbol ?? "No Suit")")
    }
    
    var isItAOneEyedJack : Bool { rank == .jack && ( suit == .hearts || suit == .spades ) }
    
    var isItATwoEyedJack : Bool { rank == .jack && ( suit == .diamonds || suit == .clubs ) }
    
    
    init(rank: Rank? = nil, suit: Suit? = nil, coin: Coin? = nil) {
        self.rank = rank
        self.suit = suit
        self.coin = coin
    }
}
