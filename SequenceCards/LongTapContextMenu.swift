//
//  LongTapContextMenu.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/9/23.
//

import SwiftUI

struct LongTapContextMenu: View {
    @ObservedObject var game: CleverJacksGame
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        //                        .contextMenu {
        //
        //                            Picker("Classic Board", selection: $classicView) {
        //                                Text("Classic Board").tag(true)
        //                                Text("Random Board").tag(false)
        //                            }
        //                            .pickerStyle(.menu)
        //
        //                            Divider()
        //
        //                            Picker("Number of Players", selection: $noOfPlayers) {
        //                                Text("Two").tag(2)
        //                                Text("Three").tag(3)
        //                            }
        //                            .pickerStyle(.menu)
        //
        //                            .onChange(of: noOfPlayers) { noOfPlayers in
        //                                game.minPlayers = noOfPlayers
        //                            }
        //                            .onChange(of: classicView){ classicView in
        //                                game.classicView = classicView
        //                            }
        //                        }
        EmptyView()
            
        
    }
}

//#Preview {
//    SettingsView(game: CleverJacksGame())
//}

struct ContextMenuPreviews: PreviewProvider {
    static var previews: some View {
        LongTapContextMenu(game: CleverJacksGame())
    }
}
