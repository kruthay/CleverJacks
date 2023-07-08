//
//  ContentView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = SequenceGame()
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    @State var size: CGFloat = 0.5
    var body: some View {
        VStack {
            Group {
                Spacer()
                // Display the game title.
                Text("Sequence")
                    .fontDesign(.serif)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
            }
            if game.matchAvailable {
                Button {
                    impactHeavy.impactOccurred()
                    game.startMatch()
                } label: {
                    Label(
                        title: {  },
                        icon: { Image(systemName: "play.fill")  }
                    )
                    .font(.system(size: 40))
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .scaleEffect(size)
                    
                }
                .disabled(!game.matchAvailable)
                .onAppear() {
                    withAnimation(self.repeatingAnimation) { self.size = 1.8 }
                }
            }
            else {
                Button {
                    game.startMatch()
                } label: {
                    //                Label("Play", systemImage: !game.matchAvailable ? "play.fill" : "play")
                    Label(
                        title: {  },
                        icon: { Image(systemName: "play.fill")  }
                    )
                    .font(.system(size: 80))
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .scaleEffect(size)
                    
                }
                .disabled(!game.matchAvailable)
            }
            Group {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
                Button("Remove All Matches") {
                    impactHeavy.impactOccurred()
                    Task {
                        await game.removeMatches()
                    }
                    
                }
                .disabled(!game.matchAvailable)
            if !game.matchAvailable {
                Button("LogIn to GameCenter") {
                    Task {
                        if !game.playingGame {
                            game.authenticatePlayer()
                        }
                    }
                }
            }
            Spacer()
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
    
//    #Preview {
//        ContentView()
//        
//    }


struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
