//
//  MeetItemsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/25/23.
//

import SwiftUI

struct MeetItemsView: View {
    @ObservedObject var game : TutorialCleverJacksGame
    @State var showItems : Int = 0
    
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    
    var body: some View {
        GeometryReader {
            proxy in
        VStack {

                AdaptiveStack(isItAVStack:  proxy.size.width < proxy.size.height) {
                    
                    if showItems >= 2 {
                        VStack {
                            
                            if showItems < 3 {
                                Text("The Board")
                                    .font(.title3)
                                    .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                            }
                            
                            TutorialBoardView(game: game, size : CGSize(width: min(proxy.size.width/13,proxy.size.height/15) ,
                                                                        height: max(proxy.size.height/15, proxy.size.width/21)))
                            .padding()
                            
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    

                    Spacer()
                    if showItems >= 0 && showItems < 3 {
                        
                        HStack {
                            Spacer()
                            
                            Text("Coins")
                                .font(.title3)
                            CoinView(coin: .blue)
                            CoinView(coin: .red)
                            CoinView(coin: .green)
                            Spacer()
                            
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    Spacer()
                    
                    if showItems >= 1 {
                        HStack {
                            if showItems < 3 {
                                Text("Cards")
                                    .font(.title3)
                                    .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                            }
                            
                            TutorialPlayerCardsView(game: game)
                                .onAppear {
                                    game.myTurn = true
                                }
                            Image(systemName: "arrow.left")
                                .fontWeight(.bold)
                                .opacity(game.tutorial && showItems >= 3 ? 0.4 : 0)
                                .scaleEffect(game.tutorial && showItems >= 3 ? 1.8 : 1)
                                .offset(x: game.tutorial  && showItems >= 3  ? 10 : 40)
                                .animation(self.repeatingAnimation, value: game.tutorial && game.inSelectionCard == nil && showItems >= 3 )
                            
                        }
                        .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
                    }
                    Spacer()
                    
                }
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
        while showItems <= 3 {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 1.5)) {
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
