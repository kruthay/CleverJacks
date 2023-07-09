//
//  ContentView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game = SequenceGame()
    @Environment(\.colorScheme) var colorScheme
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    @State var noOfPlayers: Int = 2
    @State var classicView: Bool = true
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    @State var showSettings: Bool = false
    @State var size: CGFloat = 0.8
    var body: some View {
        VStack {
            Group {
                Spacer()
                // Display the game title.
                
                HStack {
                    Image(colorScheme == .dark ? "SequenceLogo Dark" : "SequenceLogo")
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    Text("Sequence")
                        .fontDesign(.serif)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
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
                    showSettings.toggle()
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
            
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gear")
            }
            
            
//            if !game.matchAvailable {
//                Button("GameCenter") {
//                    Task {
//                        if !game.playingGame {
//                            game.authenticatePlayer()
//                        }
//                    }
//                }
//            }
            Spacer()
        }
        
        
        // Authenticate the local player when the game first launches.
        .onAppear {
            if !game.playingGame {
                game.authenticatePlayer()
            }
            else {
                game.resetGame()
            }
        }
        .fullScreenCover(isPresented: $game.playingGame ) {
            GameView(game:game)
        }
        // Display the game interface if a match is ongoing.
        
        
        .sheet(isPresented: $showSettings ) {
            
            VStack {
                Spacer()
                Text("Game Style")
                    .font(.title)

                Spacer()
                Text("Board Style")
                
                Picker("Classic Board", selection: $classicView) {
                    Text("Classic Board").tag(true)
                    Text("Random Board").tag(false)
                }
                .pickerStyle(.segmented)
                Spacer()
                Divider()
                Spacer()
                Text("Number of Players")
                Picker("Number of Players", selection: $noOfPlayers) {
                    Text("Two").tag(2)
                    Text("Three").tag(3)
                }
                .pickerStyle(.segmented)
                Spacer()
                Button("Remove All Matches") {
                    impactHeavy.impactOccurred()
                    Task {
                        await game.removeMatches()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!game.matchAvailable)
                Spacer()
            }
            .presentationDetents([.medium])
            
        }

        .onChange(of: noOfPlayers) { noOfPlayers in
            game.minPlayers = noOfPlayers
        }
        .onChange(of: classicView){ classicView in
            game.classicView = classicView
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
