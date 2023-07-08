//
//  PlayerCardsView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct PlayerCardsView: View {
    @ObservedObject var game: SequenceGame
    let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    var size: CGSize
    var horizontalView : Bool = false
    var defaultCards = [Card(rank: .ace, suit: .clubs), Card(rank: .jack, suit: .hearts), Card(rank: .jack, suit: .spades)]
    var body: some View {
        if horizontalView {
            VStack{
                    ForEach(game.localParticipant?.cardsOnHand ?? defaultCards){ card in
                        CardView(card: card, size: size )
                            .offset(x: game.inSelectionCard == card ? -20 : 0 )
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
        else {
            HStack{
                ForEach(game.localParticipant?.cardsOnHand ?? defaultCards){ card in
                    CardView(card: card, size: size )
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
}

//#Preview {
//    PlayerCardsView()
//}
struct PlayerCardsPreviews: PreviewProvider {
    static var previews: some View {
        PlayerCardsView(game: SequenceGame(), size: CGSize(width: 30, height: 50))
    }
}
