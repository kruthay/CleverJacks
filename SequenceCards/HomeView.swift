//
//  HomeView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/11/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var game = CleverJacksGame()
    @Environment(\.colorScheme) var colorScheme
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    @State var showSettings: Bool = false
    @State var size: CGFloat = 1.8
    var body: some View {
        VStack {
            
            VStack {
                VStack {
                    // Display the game title.
                    Spacer()
                    HStack {
                        Image(colorScheme == .dark ? "SequenceLogo Dark" : "SequenceLogo")
                            .resizable()
                            .frame(width: 80, height: 80)
                        
                        Text("Clever Jacks")
                            .fontDesign(.serif)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                
                VStack{
                    Spacer()
                    
                    Button {
                        impactHeavy.impactOccurred()
                        game.startMatch()
                        showSettings = false
                        
                    } label: {
                        Label(
                            title: { },
                            icon: { Image(systemName: "play.fill")  }
                        )
                        .font(.system(size: 40))
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                        
                        
                    }
                    .scaleEffect(game.matchAvailable ? size : 1)
                    .animation(self.repeatingAnimation, value: game.matchAvailable)
                    .hoverEffect(.lift)
                    .disabled(!game.matchAvailable)
                    
                    
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                    .hoverEffect(.lift)
                    Spacer()
                }
                
            }
            
            
            .sheet(isPresented: $showSettings ) {
                SettingsView(game: game)
                    .presentationDetents([.medium])
                
            }
            Spacer()
        }
    }
}


struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView(game: CleverJacksGame())
    }
}
