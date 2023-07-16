//
//  ContentView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = CleverJacksGame()
    var body: some View {
        ZStack {
            if game.playingGame {
                ZStack {
                    GameView(game:game)
                        .transition(.scale)
                }
            }
            else {
                HomeView(game: game)
            }
        }

        .onAppear {
            if !game.playingGame {
                game.authenticatePlayer()
            }
            
        }
    }
}


struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
