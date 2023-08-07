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
                    GameView()
            }
            else {
                HomeView()    
            }
        }
        .onAppear {
                if !game.playingGame {
                    game.authenticatePlayer()
                }
        }
        .environmentObject(game)
    }
        
}


struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
