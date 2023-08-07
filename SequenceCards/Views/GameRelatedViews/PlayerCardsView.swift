//
//  PlayerCardsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct PlayerCardsView: View {
    @EnvironmentObject var game: CleverJacksGame
    let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    var size: CGSize
    @State var isItAVStack : Bool
    var body: some View {
            AdaptiveStack(isItAVStack: isItAVStack ){
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
            .onAppear {
                if game.myCards.isEmpty {
                    game.resetGame()
                }
            }
        }
}

struct PlayerCardsPreviews: PreviewProvider {
    static var previews: some View {
        PlayerCardsView( size: CGSize(width: 30, height: 50), isItAVStack: true)
            .environmentObject(CleverJacksGame())
    }
}
