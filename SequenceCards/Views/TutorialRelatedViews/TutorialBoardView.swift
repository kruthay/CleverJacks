//
//  TutorialBoardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/16/23.
//

import SwiftUI

struct TutorialBoardView: View {
    @ObservedObject var game: TutorialCleverJacksGame = TutorialCleverJacksGame()
    var size : CGFloat = 50
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        Grid(horizontalSpacing: size/4, verticalSpacing: size/4){
            ForEach(game.boardCards, id: \.self){ boardRow in
                GridRow {
                    ForEach(boardRow) { card in
                        TutorialBoardCardView(game: game, card: card, size: size)
                            .opacity(card.belongsToASequence ? 0.4 : 1)
                    }
                }
            }
        }
    }
}

struct TutorialBoardViewPreviews: PreviewProvider {
    static var previews: some View {
        TutorialBoardView()
    }
}
