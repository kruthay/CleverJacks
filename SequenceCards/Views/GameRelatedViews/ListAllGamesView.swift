//
//  ListAllGamesView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 8/8/23.
//

import SwiftUI

struct ListAllGamesView: View {
    @EnvironmentObject var game: CleverJacksGame
    var body: some View {
        NavigationStack {
            List(game.allOpenMatches, id : \.self) { _ in
//                NavigationLink("\(match.)", destination: Text(val.description))
                Text("Hey")
            }
        }
    }
        
}

struct ListAllGamesView_Previews: PreviewProvider {
    static var previews: some View {
        ListAllGamesView()
            .environmentObject(CleverJacksGame())
    }
}
