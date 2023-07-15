//
//  GameOverAlert.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/15/23.
//

import SwiftUI

struct GameOverAlert: View {
    @ObservedObject var game: CleverJacksGame
    @Environment(\.colorScheme) var colorScheme
    var showAlertForTesting = false
    var body: some View {
        
            ZStack {
                if game.youWon || game.youLost || showAlertForTesting {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .background(colorScheme == .dark ? .black : .white)
                VStack {
                    Spacer()
                    if game.youWon {
                        Text("Congrats! You Won")
                            .fontDesign(.serif)
                            .frame(height: 50)
                            .layoutPriority(2)
                    }
                    else {
                        Text("Oops! You Lost")
                            .fontDesign(.serif)
                            .frame(height: 50)
                            .layoutPriority(2)
                    }
                    Spacer()
                }
                .layoutPriority(1)
                .frame(width: 240, height: 80, alignment: .bottom)
                

            }
        }
            .transition(.scale)
    }
}


struct GameOverAlertPreviews: PreviewProvider {
    
    static var previews: some View {
        GameOverAlert(game: CleverJacksGame(), showAlertForTesting: true)
    }
}
