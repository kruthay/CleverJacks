//
//  MiniBoardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 8/5/23.
//

import SwiftUI

struct MiniBoardView: View {
    @State var board = MiniBoard(direction: .diagonal)
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
        .onAppear {
            Task(priority: .low) {
                await delayAnimation()
            }
        }
        .onDisappear {
            board.reset()
            board.numberOfAnimations = 0
        }
        }
    private func delayAnimation() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        while board.numberOfAnimations != 3 {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if !board.allValuesUpdated {
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
