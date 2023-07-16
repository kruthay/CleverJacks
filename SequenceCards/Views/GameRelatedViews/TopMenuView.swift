//
//  TopMenuView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/15/23.
//

import SwiftUI

struct TopMenuView: View {
    @ObservedObject var game: CleverJacksGame
    @State private var showForfeitAlert: Bool = false
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
                showForfeitAlert = true
            }
            .hoverEffect(.lift)
        }
        .padding(.horizontal)
        .alert(isPresented:$showForfeitAlert) {
            Alert(
                title: Text("Are you sure you want to forfeit this match?"),
                message: Text("Your opponent will be awarded the win"),
                primaryButton: .destructive(Text("Forfeit")) {
                    Task {
                        await game.forfeitMatch()
                    }
                },
                secondaryButton: .cancel()
            )
        }

    }
}

struct TopMenuViewPreviews: PreviewProvider {
    static var previews: some View {
        TopMenuView(game: CleverJacksGame())
    }
}
