//
//  GameView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var game: SequenceGame
    @State private var showMessages: Bool = false
    
    //    @GestureState private var magnifyBy = 1.0
    //
    //    var magnification: some Gesture {
    //        MagnifyGesture()
    //            .updating($magnifyBy) { value, gestureState, transaction in
    //                gestureState = value.magnification
    //            }
    //    }

    
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    game.quitGame()
                }
                Spacer()
                Button {
                    Task {
                        await game.refresh()
                    }

                } label: {
                    Text(Image(systemName: "arrow.clockwise"))
                }
                Spacer()
                
                Button("Forfeit") {
                    Task {
                        await game.forfeitMatch()
                    }
                }
            }
            .padding(.horizontal)
            Divider()
            HStack  {
                Spacer()
                HStack {
                    game.myAvatar
                        .resizable()
                        .frame(width: 25.0, height: 25)
                        .clipShape(Circle())
                        .wiggling(toWiggle: game.myTurn)
                    Text(game.myName == "" ? "SomeName" : game.myName)
                        .lineLimit(2)
                        .font(.caption)
                    Text(String(game.myNoOfSequences))
                }
                .padding(4.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                )
                .opacity(game.myTurn ? 1 : 0.5)
                Spacer()
                HStack {
                    game.opponentAvatar
                        .resizable()
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                        .wiggling(toWiggle: !game.myTurn)
                    
                    Text(game.opponentName)
                        .lineLimit(2)
                        .font(.caption)
                    Text(String(game.opponentNoOfSequences))
                }
                .padding(4.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                )
                .opacity(game.myTurn ? 0.5 : 1)
                Spacer()
                
            }
            Divider()
            GeometryReader {
                proxy in
                if proxy.size.width > proxy.size.height {
                    HStack {
                        BoardView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20))
                        
                        HStack{
                            if let card = game.cardCurrentlyPlayed {
                                CardView(card: card, size:CGSize(width: proxy.size.height/20, height: proxy.size.width/30) )
                            }
                            else {
                                CardView(card: Card(), size:CGSize(width: proxy.size.height/20, height: proxy.size.width/30))
                            }
                        }
                        .zIndex(3)
                        .opacity(0.6)
                        

                        PlayerCardsView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20), horizontalView: true)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else{
                    VStack {
                        BoardView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                        Spacer()
                        HStack {
                            if let card = game.cardCurrentlyPlayed {
                                CardView(card: card, size:CGSize(width: proxy.size.width/16, height: proxy.size.height/20) )
                            }
                            else {
                                CardView(card: Card(coin:.special), size:CGSize(width: proxy.size.width/16, height: proxy.size.height/20))
                            }
                        }
                        .opacity(0.5)
                        Spacer()
                        PlayerCardsView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .padding()
        .alert("Game Over", isPresented: $game.youWon, actions: {
            Button("OK", role: .cancel) {
                game.resetGame()
            }
        }, message: {
            Text("You win.")
        })
        .alert("Game Over", isPresented: $game.youLost, actions: {
            Button("OK", role: .cancel) {
                game.resetGame()
            }
        }, message: {
            Text("You lose.")
        })
        
        
        
    }
    
}


struct MessageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isPressed ? "bubble.left.fill" : "bubble.left")
                .imageScale(.medium)
            Text("Text Chat")
        }
        .foregroundColor(Color.blue)
    }
}

struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView(game: SequenceGame())
    }
}
