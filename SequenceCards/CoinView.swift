//
//  CoinView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct CoinView: View {
    @Environment(\.colorScheme) var colorScheme
    var coin : Coin = .special
    var width : CGFloat
    var body: some View {
        Circle()
            .fill(coin.color)
            .strokeBorder(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3.5)
            .frame(width: width)
    }
}

#Preview {
    CoinView(width: 17)
}
