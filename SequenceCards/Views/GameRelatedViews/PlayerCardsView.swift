//
//  PlayerCardsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct PlayerCardsView: View {
    @ObservedObject var game: CleverJacksGame
    let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    var size: CGSize
    
    var body: some View {
            AdaptiveStack(isItAVStack: false){
                ForEach(game.myCards){ card in
                    CardView(card: card, size: size )
                        .hoverEffect(.lift)
                        .offset(y: game.inSelectionCard == card ? -20 : 0 )
                        .onTapGesture {
                            if game.myTurn {
                                withAnimation {
                                    game.inSelectionCard = game.inSelectionCard != card ? card : nil
                                }
                                impactSoft.impactOccurred()
                            }
                        }
                    
                }
            }
        }
}

struct PlayerCardsPreviews: PreviewProvider {
    static var previews: some View {
        PlayerCardsView(game: CleverJacksGame(), size: CGSize(width: 30, height: 50))
    }
}
