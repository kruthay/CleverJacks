//
//  Deck.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

struct Deck : Identifiable {
    var cards: [Card] = []
    var id = UUID()
    init() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }
}
