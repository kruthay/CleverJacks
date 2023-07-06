//
//  Coin.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import SwiftUI
enum Coin : Codable, CaseIterable {
    case blue
    case green
    case red
    case special
    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .red:
            return .red
        case .special:
            return Color.secondary
        }
    }
}
