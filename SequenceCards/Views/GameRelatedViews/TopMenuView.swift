//
//  TopMenuView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/15/23.
//

import SwiftUI

struct TopMenuView: View {
    @ObservedObject var game: CleverJacksGame
    var body: some View {
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

    }
}

struct TopMenuViewPreviews: PreviewProvider {
    static var previews: some View {
        TopMenuView(game: CleverJacksGame())
    }
}
