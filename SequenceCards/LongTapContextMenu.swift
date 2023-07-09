//
//  LongTapContextMenu.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/9/23.
//

import SwiftUI

struct LongTapContextMenu: View {
    @ObservedObject var game: SequenceGame
    @State var classicView: Bool = true
    @State var noOfPlayers: Int = 2
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        Text("Turtle Rock")
            .padding()
            
        
    }
}

//#Preview {
//    SettingsView(game: SequenceGame())
//}

struct ContextMenuPreviews: PreviewProvider {
    static var previews: some View {
        LongTapContextMenu(game: SequenceGame())
    }
}
