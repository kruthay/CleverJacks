//
//  HomeView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/11/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var game = CleverJacksGame()
    
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    
    @State var showSettings: Bool = false
    var body: some View {
        VStack {
            Spacer()
            LogoAndNameView()
            Spacer()
            Spacer()
            StartButtonView(game: game)
            Spacer()
            Spacer()
            Button("Settings") {
                showSettings.toggle()
            }
            .buttonStyle(SettingsButtonStyle())
            .hoverEffect(.lift)
            Spacer()
        }
        .sheet(isPresented: $showSettings ) {
            SettingsView(game: game)
                .presentationDetents([.medium])
            
        }
    }
}


struct HomeViewPreviews: PreviewProvider {
    static var previews: some View {
        HomeView(game: CleverJacksGame())
    }
}


struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: "gear")
        .foregroundColor(Color.blue)
    }
}
