//
//  MeetItemsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/25/23.
//

import SwiftUI

struct MeetItemsView: View {
    @ObservedObject var game : TutorialCleverJacksGame
    @State var showItems : Int = -1
    
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    
    var body: some View {
        VStack {
            GeometryReader {
                proxy in
                AdaptiveStack(isItAVStack:  proxy.size.width < proxy.size.height) {
                    
                    if showItems >= 3 {
                        VStack {

                            if showItems < 4 {
                                Text("The Board")
                                    .font(.title3)
                                    .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                            }
                            
                            TutorialBoardView(game: game, size : proxy.size.width < proxy.size.height ? proxy.size.height/16.5 : proxy.size.height/12.5)
                                .padding()
                            
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    
                    Spacer()
                    
                    if showItems <= 0 {
                        HStack {
                            Spacer()
                            LogoAndNameView()
                                .scaleEffect(1.2)
                            Spacer()
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    
                    
                    Spacer()
                    if showItems >= 1 && showItems < 4 {
                        
                        HStack {
                            Spacer()
                            
                            Text("Coins")
                                .font(.title3)
                            CoinView(coin: .blue, width : 20)
                            CoinView(coin: .red, width : 20)
                            CoinView(coin: .green, width : 20)
                            Spacer()
                            
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    Spacer()
                    
                    if showItems >= 2 {
                        HStack {
                            if showItems < 4 {
                                Text("Cards")
                                    .font(.title3)
                                    .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                            }
                            
                            TutorialPlayerCardsView(game: game,size: proxy.size.height/17 )
                                .onAppear {
                                    game.myTurn = true
                                }
                            Image(systemName: "arrow.left")
                                .fontWeight(.bold)
                                .opacity(game.tutorial && showItems >= 3 ? 0.4 : 0)
                                .scaleEffect(game.tutorial && showItems >= 3 ? 1.8 : 1)
                                .animation(self.repeatingAnimation, value: game.tutorial && game.inSelectionCard == nil && showItems >= 3 )
                            
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    Spacer()
                    
                }
                .position(.init(x: proxy.size.width/2, y: proxy.size.height/2))
                .onAppear() {
                    game.tutorial = true
                    game.startTutorialGame()
                    Task {
                        await delayAnimation()
                    }
                }
            }
        }
        
    }
    private func delayAnimation() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        while showItems <= 4 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            withAnimation(.easeInOut(duration: 1)) {
                showItems += 1
            }
        }
    }
}



struct MeetItemsViewPreviews: PreviewProvider {
    static var previews: some View {
        MeetItemsView(game : TutorialCleverJacksGame())
    }
}
