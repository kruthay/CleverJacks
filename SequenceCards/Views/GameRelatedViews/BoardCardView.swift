//
//  BoardCardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct BoardCardView: View {
    @State private var phase = 0.0
    @EnvironmentObject var game: CleverJacksGame
    var card: Card
    var size: CGFloat
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        CardView(card: card, size : size)
            .opacity ( game.inSelectionCard == nil || game.canChooseThisCard(card) ? 1 : 0.5)
            .scaleEffect(game.canChooseThisCard(card) ? 1.15 : 1)
            
        
            .wiggling(toWiggle: game.canChooseThisCard(card))
            .onTapGesture {
                if game.canChooseThisCard(card) && game.myTurn {
                    withAnimation{
                        if game.selectACard(card) != nil {
                            game.inSelectionCard = nil
                            if game.auto {
                                Task {
                                    await delayAutomaticTurn()
                                    game.automaticTurn()
                                }
                            }
                        }
                        impactHeavy.impactOccurred()
                    }
                }
            }
    }
    private func delayAutomaticTurn() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
    }
}

struct BoardCardViewPreviews: PreviewProvider {
    static var previews: some View {
        BoardCardView( card: Card(rank: .queen, suit: .clubs), size: 60)
            .environmentObject(CleverJacksGame())
    }
}
