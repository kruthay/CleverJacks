//
//  TopMenuView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/15/23.
//

import SwiftUI

struct TopMenuView: View {
    @EnvironmentObject var game: CleverJacksGame
    @State private var showForfeitAlert: Bool = false
    @State private var showResetAlert: Bool = false
    
    var body: some View {
        HStack {
            Button("Back") {
                withAnimation {
                    game.quitGame()
                }
            }
            .hoverEffect(.lift)
            Spacer()
            if !game.auto {
                Button {
                    game.isLoading = true
                    game.refresh()
                } label: {
                    Text(Image(systemName: "arrow.clockwise"))
                }
                
                if game.isLoading  {
                    ProgressView()
                }
            }
            Spacer()
            if game.auto == true {
                Button("Reset", role: .destructive) {
                    showResetAlert = true
                }
            }
            else {
                Button("Forfeit", role: .destructive) {
                    showForfeitAlert = true
                }
                .hoverEffect(.lift)
                .disabled(game.isGameOver)
            }
        }
        .padding(.horizontal)
        
        .alert(
            Text("Are you sure you want to forfeit this match?"),
            isPresented: $showForfeitAlert ) {
                    Button("Forfeit", role: .destructive) {
                        Task {
                            await game.forfeitMatch()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        withAnimation {
                            showForfeitAlert = false
                        }
                    }
            } message: { Text("Your opponent will be awarded the win")
            }
            .alert(
                Text("Are you sure you want to Reset this match?"),
                isPresented: $showResetAlert ) {
                        Button("Restart", role: .destructive) {
                            Task {
                                game.startAutoGame(newGame: true)
                            }
                        }
                        Button("Cancel", role: .cancel) {
                            withAnimation {
                                showForfeitAlert = false
                            }
                        }
                } message: {                }

    }
}

struct TopMenuViewPreviews: PreviewProvider {
    static var previews: some View {
        TopMenuView()
            .environmentObject(CleverJacksGame())
    }
}
