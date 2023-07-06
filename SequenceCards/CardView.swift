//
//  CardView.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI
    
struct CardView: View {
    let card: Card
    let size: CGSize
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5))
            if let rank = card.rank, let suit = card.suit {
                VStack{
                    HStack {
                        Text(String(rank.symbol)).fontWeight(.heavy)
                            .font(.system(size:size.height/3.5))
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text(suit.symbol)
                            .font(.system(size:size.height/3.5))
                    }
                }
                
            }
            CoinView(coin: card.coin ?? .red, width: size.height/3.5)
                .opacity( card.coin != nil ? 1 : 0 )
            
        }
        .aspectRatio(0.65, contentMode: .fit)
        .frame(width: size.width, height: size.height, alignment: .center)

        .opacity(isItAnEmpty(card: card) ? 0 : 1 )
    }
    
    func isItAnEmpty(card : Card) -> Bool {
        return card.rank == nil && card.suit == nil && card.coin == nil
    }
}

#Preview {
                                CardView(card: Card(rank: .jack, suit: .clubs), size:CGSize(width: 30, height: 50))
}

//    struct CardViewPreviews: PreviewProvider {
//        static var previews: some View {
//            CardView(card: Card(rank: .jack, suit: .clubs))
//        }
//    }
