//
//  ContentView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct ContentView: View {
    @State var game = SequenceGame()
    var body: some View {
        VStack {
            // Display the game title.
            Text("Turn-Based Game")
                .font(.title)
            
            Form {
                Section("Manage Matches") {
                    // Add the start button to initiate a turn-based match.
                    Button("Start Match") {
                        game.startMatch()
                    }
                    .disabled(!game.matchAvailable)
                    
                    Button("Remove All Matches") {
                        Task {
                            await game.removeMatches()
                        }
                    }
                    .disabled(!game.matchAvailable)
                }
            }
        }
        // Authenticate the local player when the game first launches.
        .onAppear {
            if !game.playingGame {
                game.authenticatePlayer()
            }
        }
        // Display the game interface if a match is ongoing.
        .fullScreenCover(isPresented: $game.playingGame) {
            GameView(game:game)
        }
    }
}

#Preview {
    ContentView()
        
}
