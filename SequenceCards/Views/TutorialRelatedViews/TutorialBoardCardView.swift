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
    var size: CGSize
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
                        }
                        impactHeavy.impactOccurred()
                    }
                }
            }
    }

}

struct TutorialBoardCardViewPreviews: PreviewProvider {
    static var previews: some View {
        TutorialBoardCardView(game:TutorialCleverJacksGame(), card: Card(rank: .queen, suit: .clubs), size: CGSize(width: 30, height: 50))
    }
}
