//
//  PlayerView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/9/23.
//

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var game: CleverJacksGame
    var isItAVStack : Bool = true
    var body: some View {
        AdaptiveStack(isItAVStack: !isItAVStack)  {
            Spacer()
            HStack {
                game.myAvatar
                    .resizable()
                    .frame(width: 20.0, height: 20)
                    .clipShape(Circle())
                    .wiggling(toWiggle: game.myTurn)
                if game.numberOfPlayers == 2 && isItAVStack {
                    Text(game.myName == "" ? "You" : game.myName)
                        .lineLimit(2)
                        .font(.caption)
                }
                Text(String(game.myNoOfSequences))
            }
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(game.myCoin?.color ?? .blue, lineWidth: 2)
            )
            .opacity(game.myTurn ? 1 : 0.5)
            Spacer()
            HStack {
                game.opponentAvatar
                    .resizable()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                    .wiggling(toWiggle: game.whichPlayersTurn == game.opponent?.player || (game.auto && !game.myTurn) )
                if game.numberOfPlayers == 2  && isItAVStack {
                    Text(game.opponentName)
                        .lineLimit(2)
                        .font(.caption)
                }
                Text(String(game.opponentNoOfSequences))
            }
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(game.opponentCoin?.color ?? .green, lineWidth: 2)
            )
            .opacity(game.whichPlayersTurn == game.opponent?.player ? 1 : 0.5)
            Spacer()
            if game.numberOfPlayers > 2 {
                HStack {
                    game.opponent2Avatar
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .wiggling(toWiggle: game.whichPlayersTurn == game.opponent2?.player )
                    Text(String(game.opponent2NoOfSequences))
                }
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.opponent2Coin?.color ?? .red, lineWidth: 2)
                )
                .opacity(game.whichPlayersTurn == game.opponent2?.player ? 1 : 0.5)
                Spacer()
            }
        }
    }
}

struct PlayerViewPreviews : PreviewProvider {
    static var previews: some View {
        PlayerView()
            .environmentObject(CleverJacksGame())
    }
}
