//
//  TutorialPlayerCardsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/16/23.
//

import SwiftUI

struct TutorialPlayerCardsView: View {
    @ObservedObject var game: TutorialCleverJacksGame
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
        }
}

struct TutorialPlayerCardsPreviews: PreviewProvider {
    static var previews: some View {
        TutorialPlayerCardsView(game: TutorialCleverJacksGame(), size: CGSize(width: 30, height: 50), isItAVStack: true)
    }
}
