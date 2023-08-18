//
//  TutorialBoardCardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/16/23.
//

import SwiftUI

struct TutorialBoardCardView: View {
    @State private var phase = 0.0
    @ObservedObject var game: TutorialCleverJacksGame
    var card: Card
    var size: CGFloat
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    
    var body: some View {
        ZStack {
            CardView(card: card, size : size)
                .opacity ( game.inSelectionCard == nil || game.canChooseThisCard(card) ? 1 : 0.2)
                .scaleEffect(game.canChooseThisCard(card) ? 1.15 : 1)
                .wiggling(toWiggle: game.canChooseThisCard(card))
                .onTapGesture {
                    if game.canChooseThisCard(card) && game.myTurn {
                        withAnimation{
                            if game.selectACard(card) != nil {
                                game.inSelectionCard = nil
                            }
                            impactHeavy.impactOccurred()
                        }
                    }
                }
                Image(systemName: "arrow.up")
                    .fontWeight(.bold)
                    .offset(y: game.canChooseThisCard(card) ? 50 : 30)
                    .opacity(game.canChooseThisCard(card) && !game.inSelectionCard!.isItATwoEyedJack ? 1 : 0)
                    .scaleEffect(game.canChooseThisCard(card) ? 2 : 0.5)
                    .animation(game.canChooseThisCard(card) ? self.repeatingAnimation : Animation.default , value: game.canChooseThisCard(card))
        }
    }

}

struct TutorialBoardCardViewPreviews: PreviewProvider {
    static var previews: some View {
        TutorialBoardCardView(game:TutorialCleverJacksGame(), card: Card(rank: .queen, suit: .clubs), size: 60)
    }
}
