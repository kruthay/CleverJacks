//
//  StartButtonView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/14/23.
//

import SwiftUI

struct StartButtonView: View {
    @ObservedObject var game: CleverJacksGame
    
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    @State var size: CGFloat = 1.8
    
    var repeatingAnimation: Animation {
        Animation
            .easeInOut(duration: 2) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }

    var body: some View {
        Button {
            impactHeavy.impactOccurred()
            game.startMatch()            
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
    }
}


struct StartButtonViewPreviews : PreviewProvider {
    static var previews: some View {
        StartButtonView(game: CleverJacksGame())
    }
}
