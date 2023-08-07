//
//  CardView.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import SwiftUI

struct CardView: View {
    var card: Card
    let size: CGSize
    @Environment(\.colorScheme) var colorScheme
    @State private var flipped: Bool = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.width/10)
                .strokeBorder(style: StrokeStyle(lineWidth: size.width/25))
                .background(colorScheme == .dark ? .black : .white)
            if !flipped {
                if let rank = card.rank, let suit = card.suit {
                    VStack{
                        HStack {
                            Text(String(rank.symbol)).fontWeight(.heavy)
                                .font(.system(size:size.height/3.5))
                            Spacer()
                        }
                        
                        if let faceImage = rank.faceImage {
                            if card.isItATwoEyedJack {
                                HStack {
                                    faceImage
                                        .font(.system(size:size.height/5.5))
                                    faceImage
                                        .font(.system(size:size.height/5.5))
                                }
                            }
                            else {
                                faceImage
                                    .font(.system(size:size.height/5.5))
                            }
                        }
                        else {
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Text(suit.symbol)
                                .font(.system(size:size.height/3.5))
                        }
                    }
                   
                        
                }
                CoinView(coin: card.coin ?? .special, width: size.height/3.5)
                    .opacity( card.coin != nil ? 1 : 0 )
                    
                
            }
            else {
                if let rank = card.rank, let suit = card.suit {
                    VStack{
                        HStack {
                            Text(String(rank.symbol)).fontWeight(.heavy)
                                .font(.system(size:size.height/3.5))
                            Spacer()
                        }
                        
                        if let faceImage = rank.faceImage {
                            if card.isItATwoEyedJack {
                                HStack {
                                    faceImage
                                        .font(.system(size:size.height/5.5))
                                    faceImage
                                        .font(.system(size:size.height/5.5))
                                }
                            }
                            else {
                                faceImage
                                    .font(.system(size:size.height/5.5))
                            }
                        }
                        else {
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Text(suit.symbol)
                                .font(.system(size:size.height/3.5))
                        }
                    }
                    CoinView(coin: card.coin ?? .special, width: size.height/3.5)
                        .opacity( card.coin != nil ? 1 : 0 )
                        
                }
            }
            
            
        }
        
        .aspectRatio(0.65, contentMode: .fit)
        .frame(width: size.width, height: size.height, alignment: .center)
        .rotation3DEffect(
            flipped ? Angle(degrees: 180) : .zero,
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .animation(.easeInOut(duration: 1.5), value: flipped)
        .onChange(of: card.coin ) { _ in
                 flipped.toggle()
            print("Card Changed? \(card)")
        }        
    }
}


struct CardViewPreviews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card(coin: .special), size:CGSize(width: 300, height: 500))
    }
}

