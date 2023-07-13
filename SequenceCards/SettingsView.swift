//
//  SettingsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/9/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var game: CleverJacksGame
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        VStack {
            Spacer()
            Text("Game Style")
                .font(.title)

            Spacer()
            VStack(alignment:.leading) {
                Text("Board Style")
            
            
            Picker("Classic Board", selection: $classicView) {
                Text("Classic Board").tag(true)
                Text("Random Board").tag(false)
            }
            .pickerStyle(.segmented)
            
            Divider()
            
            Text("Number of Players")
            Picker("Number of Players", selection: $noOfPlayers) {
                Text("Two").tag(2)
                Text("Three").tag(3)
            }
            .pickerStyle(.segmented)
            
            }
            .padding()
            Spacer()
            Button("Remove All Matches", role: .destructive) {
                impactHeavy.impactOccurred()
                Task {
                    await game.removeMatches()
                }
            }
            .buttonStyle(.bordered)
            .disabled(!game.matchAvailable)
            Spacer()
            Text(UIApplication.appVersion ?? "")
        }
        .onChange(of: noOfPlayers) { noOfPlayers in
                game.minPlayers = noOfPlayers
            }
            .onChange(of: classicView){ classicView in
                game.classicView = classicView
            }
            .padding()
    }
    
}

//#Preview {
//    SettingsView(game: CleverJacksGame())
//}

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        SettingsView(game: CleverJacksGame())
    }
}
