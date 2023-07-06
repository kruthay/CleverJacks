//
//  BoardView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct BoardView: View {
    var game: SequenceGame
    var size : CGSize
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        Grid{
            ForEach(game.board?.boardCards ?? Board().boardCards, id: \.self){ boardRow in
                GridRow {
                    ForEach(boardRow) { card in
                        BoardCardView(game: game, card: card, size: size)
                                    .opacity(card.belongsToASequence ? 0.4 : 1)
                                    
                    }

                }
            }
        }
    }
    
}

#Preview {
        BoardView(game: SequenceGame(), size: CGSize(width: 30, height: 50))
}
