//
//  MiniBoardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 8/5/23.
//

import SwiftUI

struct MiniBoardView: View {
    @State var board = MiniBoard(direction: .diagonal)
    @State var allRulesTimer = Timer.publish(every: 1.2, on: .current, in: .common).autoconnect()
    var body: some View {
        HStack{
            Text(board.direction.rawValue)
            Spacer()
            Grid{
                ForEach(board.miniBoardCards, id: \.self){ board in
                    GridRow {
                        ForEach(board) { card in
                            CardView(card: card, size : CGSize(width: 20, height: 30))
                            .opacity(card.belongsToASequence ? 0.4 : 1)
                        }
                    }
                }
            }
        }
        .onReceive(allRulesTimer) { _ in
            if board.numberOfAnimations == 3 {
                allRulesTimer.upstream.connect().cancel()
            }
            else if !board.allValuesUpdated {
                board.update()
            }
            else {
                board.reset()
            }
        }
    }
}

struct MiniBoardViewPreviews: PreviewProvider {
    static var previews: some View {
        MiniBoardView()
    }
}
