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
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    @State var showSettings: Bool = false
    @State var size: CGFloat = 0.8
    
    var body: some View {
        VStack {

            VStack {
                VStack {
                    // Display the game title.
                    Spacer()
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
                }

                VStack{
                    Spacer()
                    if game.matchAvailable {
                        Button {
                            impactHeavy.impactOccurred()
                            game.startMatch()
                            
                        } label: {
                            Label(
                                title: { },
                                icon: { Image(systemName: "play.fill")  }
                            )
                            .font(.system(size: 40))
                            .fontDesign(.serif)
                            .fontWeight(.bold)
                            .scaleEffect(size)
                            
                        }
                        .disabled(!game.matchAvailable)
                        
                        .onAppear() {
                            if game.matchAvailable {
                                withAnimation(self.repeatingAnimation) { self.size = 1.2 }
                            }
                        }
//                        .contextMenu {
//                            
//                            Picker("Classic Board", selection: $classicView) {
//                                Text("Classic Board").tag(true)
//                                Text("Random Board").tag(false)
//                            }
//                            .pickerStyle(.menu)
//                            
//                            Divider()
//                            
//                            Picker("Number of Players", selection: $noOfPlayers) {
//                                Text("Two").tag(2)
//                                Text("Three").tag(3)
//                            }
//                            .pickerStyle(.menu)
//                            
//                            .onChange(of: noOfPlayers) { noOfPlayers in
//                                game.minPlayers = noOfPlayers
//                            }
//                            .onChange(of: classicView){ classicView in
//                                game.classicView = classicView
//                            }
//                        }
                        
                    }
                    else {
                        Button {
                        } label: {
                            Label(
                                title: {  },
                                icon: { Image(systemName: "play.fill")  }
                            )
                            .font(.system(size: 40))
                            
                        }
                        .disabled(!game.matchAvailable)
                    }
                    Spacer()
                }

                VStack {
                    Spacer()
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                    Spacer()
                }
                
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
                SettingsView(game: game)
                .presentationDetents([.medium])
                
        }
        Spacer()
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
