//
//  TutorialView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/12/23.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var game: TutorialCleverJacksGame
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    
    
    var body: some View {
        VStack{
            Spacer()
            TutorialBoardView(game: game, size: CGSize(width: 30, height: 50))
            Spacer()
            Text("")
            Spacer()
            HStack {
                Spacer()
                TutorialPlayerCardsView(game: game, size:  CGSize(width: 30, height: 50), isItAVStack: false) // change
                    .onAppear {
                        game.myTurn = true
                    }
                Spacer()
                Image(systemName: "arrow.left")
                    .fontWeight(.bold)
                    .opacity(game.tutorial && game.inSelectionCard == nil ? 0.4 : 0)
                    .scaleEffect(game.tutorial && game.inSelectionCard == nil ? 1.8 : 1)
                    .offset(x: game.tutorial && game.inSelectionCard == nil  ? -30 : 0)
                    .animation(self.repeatingAnimation, value: game.tutorial && game.inSelectionCard == nil )
                
                Spacer()
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
