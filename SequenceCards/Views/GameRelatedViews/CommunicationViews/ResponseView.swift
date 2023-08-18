//
//  ResponseView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/12/23.
//

import SwiftUI
import AVFoundation

struct ResponseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showMessages: Bool = false
    @EnvironmentObject var game: CleverJacksGame
    var size : CGFloat
    @State var isItAVStack : Bool
    var body: some View {
        ZStack {
            AdaptiveStack(isItAVStack: isItAVStack) {
                Spacer()
                if !game.auto {
                    
                    Button("Message") {
                        withAnimation(.easeInOut(duration: 1)) {
                            game.showMessages = true
                        }
                    }
                    .buttonStyle(MessageButtonStyle(count: game.unViewedMessages.count))
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(game.isGameOver)
                    Spacer()
                    if let matchMessage = game.matchMessage {
                        HStack {
                            Text(matchMessage)
                                .font(.system(size: 15))
                                .minimumScaleFactor(0.001)
                        }
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                withAnimation(.easeInOut(duration: 1)) {
                                    game.matchMessage = nil
                                }
                            }

                        }
                    }
                }
                else {
                    Spacer()
                }
                
                Group {
                    Spacer()
                    if let card = game.cardCurrentlyPlayed {
                        HStack {
                            if card.isItAOneEyedJack || card.isItATwoEyedJack {
                                if let recentCard = game.cardRecentlyChanged {
                                    CardView(card: recentCard, size:size)
                                        .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                                    
                                }
                            }
                            CardView(card: card, size:size)
                                .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                                .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                        }
                    }
                    else {
                        CardView(card: Card(coin:.special), size:size)
                            .opacity(game.inSelectionCard != nil ? 1 : 0.6)
                    }
                    // Send a reminder to take their turn.
                    Spacer()
                }
                Group {
                    if game.showDiscard {
                        Button("Discard The Card") {
                            game.showDiscard = false
                            game.discardTheCard()
                        }
                    }
                    Spacer()
                }
                if !game.auto {
                    Button("Remainder") {
                        Task {
                            await game.sendReminder()
                        }
                        AudioServicesPlaySystemSound(1105)
                    }
                    .buttonStyle(RemainderButtonStyle())
                    .disabled((game.myTurn || game.isGameOver))
                    
                }
                Spacer()
                
            }
        }
        
    }
}



struct ResponseViewPreviews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            ResponseView(size: 30, isItAVStack: false)
                .environmentObject(CleverJacksGame())
        }
    }
}

struct MessageButtonStyle: ButtonStyle {
    var count : Int
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isPressed ? "bubble.left.fill" : "bubble.left")
                .overlay(
                    NotificationCountView(value: .constant(count))
                )
        }
        .foregroundColor(Color.blue)
    }
}

struct RemainderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isPressed ? "bell.and.waves.left.and.right.fill" : "bell.and.waves.left.and.right")
        }
        .foregroundColor(Color.blue)
    }
}

