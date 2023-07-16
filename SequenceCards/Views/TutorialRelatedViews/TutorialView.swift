//
//  TutorialView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/12/23.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var game: TutorialCleverJacksGame
    var body: some View {
        VStack{
            Spacer()
            Button("Start Tutorial") {
                game.startTutorialGame()
            }
            TutorialBoardView(game: game, size: CGSize(width: 30, height: 50))
            
            Spacer()
            TutorialPlayerCardsView(game: game, size:  CGSize(width: 30, height: 50), isItAVStack: false) // change
                .onAppear {
                    game.myTurn = true
                    print(game.myTurn)
                }
            Spacer()
        }
        
    }
}


struct TutorialViewPreviews: PreviewProvider {
    static var previews: some View {
        TutorialView(game: TutorialCleverJacksGame())
    }
}
