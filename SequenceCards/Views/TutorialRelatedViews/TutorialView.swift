//
//  TutorialView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/12/23.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var game: CleverJacksGame
    var body: some View {
        VStack{
            Spacer()
            BoardView(game: game, size: CGSize(width: 30, height: 50))
            Spacer()
            PlayerCardsView(game: game, size:  CGSize(width: 30, height: 50), isItAVStack: false) // change
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
        TutorialView(game: CleverJacksGame())
    }
}
