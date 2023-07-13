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
    @ObservedObject var game: CleverJacksGame
    var proxy : GeometryProxy
    let timer = Timer.publish(every: 6, on: .current, in: .common).autoconnect()
    var body: some View {
        
            Spacer()
            Button("Message") {
                withAnimation(.easeInOut(duration: 1)) {
                    showMessages = true
                }
            }
            .buttonStyle(MessageButtonStyle())
            .onTapGesture {
                presentationMode.wrappedValue.dismiss()
            }
            Spacer()
                if game.myTurn {
                    if let matchMessage = game.matchMessage {
                        HStack {
                            Text(matchMessage)
                        }
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                                withAnimation(.easeInOut(duration: 5)) {
                                    game.matchMessage = nil
                                }
                            }
                            AudioServicesPlaySystemSound(1106)
                        }
                    }
                }
                Spacer()
                
                // Send text messages as exchange items.
                
            if let card = game.cardCurrentlyPlayed {
                CardView(card: card, size:CGSize(width: proxy.size.width/16, height: proxy.size.height/20) )
            }
            else {
                CardView(card: Card(coin:.special), size:CGSize(width: proxy.size.width/16, height: proxy.size.height/20))
            }
            
            // Send a reminder to take their turn.
            Spacer()
            Spacer()
            Button {
                Task {
                    await game.sendReminder()
                }
                AudioServicesPlaySystemSound(1105)
            }  label: {
                Label(
                    title: { },
                    icon: { Image(systemName: "bell.and.waves.left.and.right")  }
                )
            }
            .disabled(game.myTurn)
        Spacer()
            .sheet(isPresented: $showMessages) {
                ChatView(game: game)
            }
            

    }
}



struct ResponseViewPreviews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            ResponseView(game: CleverJacksGame(), proxy: proxy)
        }
    }
}
