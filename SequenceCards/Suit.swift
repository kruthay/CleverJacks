//
//  Suit.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

enum Suit: Int, CaseIterable, Codable {
    case hearts = 1
    case clubs = 2
    case spades = 3
    case diamonds = 4
    var symbol: String {
        switch self {
        case .hearts:
            return "❤️"
        case .clubs:
            return "♣️"
        case .spades:
            return "♠️"
        case .diamonds:
            return "♦️"
        }
    }
    
}

