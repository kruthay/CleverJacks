//
//  SettingsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/9/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var game: CleverJacksGame
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    @State private var showingRemoveAlert = false
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        VStack {
            Spacer()
            Text("Options")
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
                Picker("Number of Players", selection: $game.minPlayers) {
                    Text("Two").tag(2)
                    Text("Three").tag(3)
                }
                .pickerStyle(.segmented)
                
            }
            .padding()
            Spacer()
            Button("Remove All Matches", role: .destructive) {
                impactHeavy.impactOccurred()
                showingRemoveAlert = true
            }
            .buttonStyle(.bordered)
            .disabled(!game.matchAvailable)
            Spacer()
            Text("45")
        }
        .padding()
        .onChange(of: classicView){ classicView in
            game.classicView = classicView
        }
        
        .alert(
            Text("Are you sure you want to remove and quit all matches?"),
            isPresented: $showingRemoveAlert ) {
                    Button("Remove", role: .destructive) {
                        Task {
                            await game.removeMatches()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        withAnimation {
                            showingRemoveAlert = false
                        }
                    }
            } message: {     Text("You can't undo this action")           }

        
    }
    
}

//#Preview {
//    SettingsView(game: CleverJacksGame())
//}

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CleverJacksGame())
    }
}
