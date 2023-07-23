//
//  HomeView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/11/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var game : CleverJacksGame
    
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    
    @State var showSettings: Bool = false
    var body: some View {
        VStack {
            Spacer()
            LogoAndNameView()
            Spacer()
            Spacer()
            StartButtonView()
            Spacer()
            Spacer()
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
                Button("Settings") {
                    showSettings.toggle()
                }
                .buttonStyle(SettingsButtonStyle())
                .hoverEffect(.lift)
                Spacer()
            }
            Spacer()
        }
        .sheet(isPresented: $showSettings ) {
            ZStack {
                SettingsView()
                    .presentationDetents([.medium])
            }
            
        }
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
