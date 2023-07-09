//
//  GameView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject var game: SequenceGame

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
                    if game.board?.numberOfPlayers == 2 {
                        Text(game.myName == "" ? "SomeName" : game.myName)
                            .lineLimit(2)
                            .font(.caption)
                    }
                    Text(String(game.myNoOfSequences))
                }
                .padding(4.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.myCoin?.color ?? .blue, lineWidth: 2)
                )
                .opacity(game.myTurn ? 1 : 0.5)
                Spacer()
                HStack {
                    game.opponentAvatar
                        .resizable()
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                    if game.board?.numberOfPlayers == 2 {
                        Text(game.opponentName)
                            .lineLimit(2)
                            .font(.caption)
                    }
                    Text(String(game.opponentNoOfSequences))
                }
                .padding(4.5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.opponentCoin?.color ?? .green, lineWidth: 2)
                )
                .opacity(game.myTurn ? 0.5 : 1)
                Spacer()
                if game.board?.numberOfPlayers ?? 0 > 2 {
                    HStack {
                        game.opponent2Avatar
                            .resizable()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                        Text(String(game.opponent2NoOfSequences))
                    }
                    .padding(4.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(game.opponent2Coin?.color ?? .red, lineWidth: 2)
                    )
                    .opacity(game.myTurn ? 0.5 : 1)
                    Spacer()
                    
                }
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
                        .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                        

                        PlayerCardsView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20), horizontalView: true)
                            .disabled(game.youWon)
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
//        .onAppear {
//            Task {
//             await game.refresh()
//            }
//        }
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


struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView(game: SequenceGame())
    }
}
