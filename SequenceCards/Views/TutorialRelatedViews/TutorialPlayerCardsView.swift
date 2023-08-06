//
//  TutorialPlayerCardsView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/16/23.
//

import SwiftUI

struct TutorialPlayerCardsView: View {
    @ObservedObject var game: TutorialCleverJacksGame = TutorialCleverJacksGame()
    let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    var size: CGSize = CGSize(width: 30, height: 50)
    var tutorialCards = [Card(rank: .ace, suit: .clubs),
                         Card(rank : .jack, suit: .diamonds),
                         Card(rank: .ten, suit: .hearts),
                         Card(rank : .jack, suit: .spades),
                         Card(rank : .king, suit: .diamonds)]
    @State var isItAVStack : Bool = false
    var body: some View {
            AdaptiveStack(isItAVStack: isItAVStack ){
                ForEach(game.myCards.isEmpty ? tutorialCards : game.myCards){ card in
                    CardView(card: card, size: size )
                        .hoverEffect(.lift)
                        .offset(y: game.inSelectionCard == card ? -20 : 0 )
                        .onTapGesture {
                            if game.myTurn {
                                withAnimation {
                                    game.inSelectionCard = game.inSelectionCard != card ? card : nil
                                    
                                }
                                impactSoft.impactOccurred()
                            }
                        }
                    
                }
            }
        }
}

struct TutorialPlayerCardsPreviews: PreviewProvider {
    static var previews: some View {
        TutorialPlayerCardsView()
    }
}
