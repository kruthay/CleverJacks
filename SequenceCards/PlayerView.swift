//
//  PlayerView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/9/23.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var game: CleverJacksGame
    var body: some View {
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
    }
}

struct PlayerViewPreviews : PreviewProvider {
    static var previews: some View {
        PlayerView(game: CleverJacksGame())
    }
}
