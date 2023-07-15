//
//  ChatView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/11/23.
//


import SwiftUI
import GameKit

struct ChatView: View {
    @ObservedObject var game: CleverJacksGame
    @State private var typingMessage: String = ""
    var id = 10
    var body: some View {
        VStack {
            // Show the opponent's name in the heading.
            HStack {
                Text("To: ").foregroundStyle(.secondary)
                game.opponentAvatar
                    .resizable()
                    .frame(width: 35.0, height: 35.0)
                    .clipShape(Circle())
                Text(game.opponentName)
            }
            .padding(10)
            // View sent messages here.
            ScrollView {
                LazyVStack(alignment: .trailing, spacing: 6) {
                    ForEach(game.messages, id: \.id) { item in
                        MessageView(message: item)
                    }
                }
                .padding(10)
            }
            // Enter text messages here.
            HStack {
                TextField("Message...\(id)", text: $typingMessage)
                    .onSubmit {
                        Task {
                            await game.sendMessage(content: typingMessage)
                            typingMessage = ""
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(minHeight: 30)
            }
            .frame(minHeight: 50)
            .padding()
        }
    }
}

struct ChatViewPreviews: PreviewProvider {
    static var previews: some View {
        ChatView(game: CleverJacksGame())
    }
}