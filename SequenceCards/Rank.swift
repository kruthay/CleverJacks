//
//  Rank.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

enum Rank : CaseIterable, Codable {
    case two , three, four, five, six, seven, eight, nine, ten
    case jack , queen, king
    case ace
    var symbol: String {
        switch self {
        case .two:
            return " 2"
        case .three:
            return " 3"
        case .four:
            return " 4"
        case .five:
            return " 5"
        case .six:
            return " 6"
        case .seven:
            return " 7"
        case .eight:
            return " 8"
        case .nine:
            return " 9"
        case .ten:
            return "10"
        case .jack:
            return " J"
        case .queen:
            return " Q"
        case .king:
            return " K"
        case .ace:
            return " A"
        }
    }
    
}
