//
//  BoardCardView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct BoardCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var phase = 0.0
    var game: SequenceGame
    var card: Card
    var size: CGSize
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
            CardView(card: card, size : size)
                .blur(radius: colorScheme != .dark || game.inSelectionCard == nil || game.canChooseThisCard(card) ? 0 : 1.2)
                .brightness(colorScheme == .dark || game.inSelectionCard == nil || game.canChooseThisCard(card) ? 0 : 0.5)
                .scaleEffect(game.canChooseThisCard(card) ? 1.15 : 1)
                .wiggling(toWiggle: game.canChooseThisCard(card))
                .onTapGesture {
                    if game.canChooseThisCard(card) && game.myTurn {
                        withAnimation{
                            if game.selectACard(card) != 0{
                                game.inSelectionCard = nil
                            }
                        }
                        impactHeavy.impactOccurred()
                    }
                }
        
        
    }
}

#Preview {
    BoardCardView(game:SequenceGame(), card: Card(rank: .ace, suit: .clubs), size: CGSize(width: 30, height: 50))
}
