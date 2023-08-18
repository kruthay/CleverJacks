//
//  CardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct CardView: View {
    var card: Card
    let size: CGFloat
    @Environment(\.colorScheme) var colorScheme
    //    @State private var flipped: Bool = false
    var body: some View {
        
        ZStack {
            VStack{
                HStack {
                    if let rank = card.rank {
                        Text(String(rank.symbol)).fontWeight(.heavy)
                        
                            .font(.system(size: size / 4))
                            .minimumScaleFactor(0.1)
                    }
                    Spacer()
                }
                
                
                if let rank = card.rank, let faceImage = rank.faceImage {
                    
                    if card.isItATwoEyedJack {
                        HStack {
                            faceImage
                            
                                .font(.system(size:size / 6))
                            
                            faceImage
                            
                                .font(.system(size:size / 6))
                        }
                    }
                    else {
                        faceImage
                            .font(.system(size:size / 6))
                    }
                      
                }
                Spacer()
                
                
                HStack {
                    Spacer()
                    if  let suit = card.suit {
                        Text(suit.symbol)
                        
                            .font(.system(size: size / 4))
                            .minimumScaleFactor(0.1)
                    }
                }
                
            }
            if let coin = card.coin {
                CoinView(coin: coin, width: size / 4)
                    .transition(.asymmetric(insertion: AnyTransition.opacity.combined(with: .scale), removal: .scale))
            }
            
        }
        .background(colorScheme == .dark ? .black : .white)
        .frame(width: size * 0.6, height: size)
        .overlay(RoundedRectangle(cornerRadius: size/20)
            .stroke(lineWidth: size/30))
    }
}


struct CardViewPreviews: PreviewProvider {
    static var previews: some View {
       
            CardView(card: Card(rank: .ten, suit: .clubs), size:60)
        
    }
}

