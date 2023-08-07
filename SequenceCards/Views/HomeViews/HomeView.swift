//
//  HomeView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/11/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var game : CleverJacksGame
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }
    @ObservedObject var tutorialGame = TutorialCleverJacksGame()
    @State var showArrow = false
    var body: some View {
        NavigationStack {
            Group {
                Spacer()
                LogoAndNameView()
                Spacer()
                Spacer()
                StartButtonView()
                Spacer()
                Spacer()
                Spacer()
            }
            HStack {
                Spacer()
                Button("Auto") {
                    withAnimation {
                        game.auto = true
                        game.startAutoGame()
                    }
                }
                .buttonStyle(ComputerPlayButtonStyle())
                .hoverEffect(.lift)
                Spacer()
                NavigationLink(destination: SettingsView()){
                    Image(systemName: "gear")
                        .foregroundColor(Color.blue)
                        .hoverEffect(.lift)
                }
                Spacer()
                VStack {
                    NavigationLink(destination: AllRules()) {
                        Image(systemName: "newspaper")
                            .foregroundColor(Color.blue)
                            .offset(y:10)
                    }
                    TutorialArrowView(show: showArrow, arrow: .up, yAxis: true)
                }
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Spacer()
                Spacer()
                Text("How to Play?")
                    .fontWeight(.light)
                    .fontDesign(.monospaced)
                    .opacity(showArrow ? 0.8: 0)
                    .animation(self.repeatingAnimation, value: showArrow)
                Spacer()
            }
            Spacer()
            
        }
        .navigationTitle("Home")
        .onAppear {
            Task {
                await delayAnimation()
            }
        }
        
    }
    private func delayAnimation() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        showArrow.toggle()
    }
}


struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CleverJacksGame())
        
    }
}


struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: "gear")
            .foregroundColor(Color.blue)
    }
}


struct ComputerPlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: "play.laptopcomputer")
            .foregroundColor(Color.blue)
    }
}
