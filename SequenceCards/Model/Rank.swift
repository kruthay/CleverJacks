//
//  Rank.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation
import SwiftUI
enum Rank :  Int, CaseIterable, Codable {
    case two = 2 , three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen, king
    case ace = 14
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
    
    var faceImage: Text? {
        switch self{
        case .king:
            return Text(Image(systemName:"crown"))
        case .queen:
            return Text(Image("tiaraLarge"))
        case .jack:
            return Text(Image(systemName:"eyebrow"))
        default :
            return nil
        }
    }
    
}
