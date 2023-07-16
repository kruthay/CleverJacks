//
//  GameOverAlert.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/15/23.
//

import SwiftUI

struct GameOverAlert: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var game : CleverJacksGame
    var size : CGSize
    var body: some View {
        
        
        if game.youWon || game.youLost {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .background(colorScheme == .dark ? .black : .white)
                VStack {
                    Spacer()
                    Text("Game Over")
                    Divider()
                    if game.youWon  {
                        Text("Congrats! You Won")
                            .fontDesign(.serif)
                            .layoutPriority(2)
                    }
                    else if  game.youLost {
                        Text("Oops! You Lost")
                            .fontDesign(.serif)
                            .layoutPriority(2)
                    }
                    Spacer()
                }
                .layoutPriority(1)
                
            }
            .frame(width: min(size.width, size.height), height: size.height/10, alignment: .bottom)
            .onAppear {
                Task {
                   await game.refresh()
                }
            }
        }
        
    }
}


struct GameOverAlertPreviews: PreviewProvider {
    
    static var previews: some View {
        GameOverAlert(game : CleverJacksGame(), size : CGSize(width: 2000, height: 100))
    }
}
