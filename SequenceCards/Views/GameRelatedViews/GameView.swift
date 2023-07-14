//
//  GameView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI
import AVFoundation


struct GameView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var game: CleverJacksGame
    let timer = Timer.publish(every: 6, on: .current, in: .common).autoconnect()
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    withAnimation {
                        game.quitGame()
                    }
                }
                .hoverEffect(.lift)
                Spacer()
                Button {
                    game.isLoading = true
                    Task {
                        await game.refresh()
                    }
                } label: {
                    Text(Image(systemName: "arrow.clockwise"))
                }
                .onReceive(timer) { _ in
                    game.isLoading = true
                    if scenePhase == .active {
                        Task {
                            await game.refresh()
                        }
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        game.isLoading = true
                        Task {
                            await game.refresh()
                        }
                    }
                }
                
                if game.isLoading {
                    ProgressView()
                }
                Spacer()
                Button("Forfeit", role: .destructive) {
                    Task {
                        await game.forfeitMatch()
                    }
                }
                .hoverEffect(.lift)
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
                        .wiggling(toWiggle: game.whichPlayersTurn == game.opponent?.player )
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
                .opacity(game.whichPlayersTurn == game.opponent?.player ? 1 : 0.5)
                Spacer()
                if game.board?.numberOfPlayers ?? 0 > 2 {
                    HStack {
                        game.opponent2Avatar
                            .resizable()
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .wiggling(toWiggle: game.whichPlayersTurn == game.opponent2?.player )
                        Text(String(game.opponent2NoOfSequences))
                    }
                    .padding(4.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(game.opponent2Coin?.color ?? .red, lineWidth: 2)
                    )
                    .opacity(game.whichPlayersTurn == game.opponent2?.player ? 1 : 0.5)
                    Spacer()
                }
            }
            Divider()
            GeometryReader {
                proxy in
                if proxy.size.width > proxy.size.height {
                    HStack {
                        Spacer()
                        BoardView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20))
                        Spacer()
                        VStack{
                            ResponseView(game:game, proxy:proxy)
                                .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                        }
                        Spacer()
                        PlayerCardsView(game: game, size : CGSize(width: proxy.size.height/12.5, height: proxy.size.width/20), horizontalView: true)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else{
                    VStack {
                        BoardView(game: game, size : CGSize(width: proxy.size.width/12.5, height: proxy.size.height/14))
                        Spacer()
                        HStack {
                            ResponseView(game: game, proxy: proxy)
                                .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                        }
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
            Text("Hurray! You win.")
        })
        .alert("Game Over", isPresented: $game.youLost, actions: {
            Button("OK", role: .cancel) {
                game.resetGame()
            }
        }, message: {
            Text("Oh No! You lose.")
        })
    }
}
struct MessageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isPressed ? "bubble.left.fill" : "bubble.left")
        }
        .foregroundColor(Color.blue)
    }
}



struct GameViewPreviews: PreviewProvider {
    static var previews: some View {
        GameView(game: CleverJacksGame())
    }
}
