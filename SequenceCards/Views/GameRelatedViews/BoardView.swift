//
//  BoardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var game: CleverJacksGame
    var size : CGFloat
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        Grid(horizontalSpacing: size/4, verticalSpacing: size/4){
            ForEach(game.boardCards, id: \.self){ boardRow in
                GridRow {
                    ForEach(boardRow) { card in
                        BoardCardView(card: card, size: size)
                            .opacity(card.belongsToASequence ? 0.4 : 1)
                        
                    }
                    
                }
            }
        }
    }
    
}


struct BoardViewPreviews: PreviewProvider {
    static var previews: some View {
        BoardView( size: 25)
            .environmentObject(CleverJacksGame())
    }
}


