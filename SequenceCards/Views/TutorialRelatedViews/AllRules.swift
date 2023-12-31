//
//  AllRules.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 8/2/23.
//

import SwiftUI



struct AllRules: View {
    @ObservedObject var game = TutorialCleverJacksGame()
    @State var showRules = 0
    
    
    @State var horizontalBoard = MiniBoard(direction: .horizontal)
    @State var verticalBoard = MiniBoard(direction: .vertical)
    @State var diagonalBoard = MiniBoard(direction: .diagonal)
    @State var cardIndexToSelectColumn = 0
    @State var cardIndexToSelectRow = 2
    
    
    var body: some View {
        NavigationStack{
        List {
            Section {
                HStack {
                    Text("Your Coin")
                        .foregroundStyle(.blue)
                    Spacer()
                    CoinView(coin:.blue, width: 20)
                }
                HStack {
                    Text("Your Cards")
                        .foregroundStyle(.red)
                    Spacer()
                    TutorialPlayerCardsView(size : 40)
                }
                NavigationLink( "Sample Play", destination: MeetItemsView(game: game))
            }
            
            Section{
                HStack {
                    Text("Choose a card from")
                        .font(.system(size:13))
                    Text("Your Cards")
                        .foregroundStyle(.red)
                        .font(.system(size:13))
                }
                HStack {
                    Text("Place")
                        .font(.system(size:13))
                    Text("Your Coin")
                        .foregroundStyle(.blue)
                        .font(.system(size:13))
                    Text("on a similar card on")
                        .font(.system(size:13))
                    Text("The Board")
                        .foregroundStyle(.green)
                        .font(.system(size:13))
                }
            } header: {
                Text("If Your Turn")
            } footer: {
                Text("This ends your turn.. Your card is exchanged.. and Opponent takes a turn")
            }
            
            Section{
                Text("5 same coins arranged either")
                MiniBoardView(board: horizontalBoard)
                MiniBoardView(board: verticalBoard)
                MiniBoardView(board: diagonalBoard)
            } header: {
                Text("What is a Sequence")
            } footer: {
                Text("Two sequences cannot have more than one common card")
            }
            
            
            Section("Winning Condition") {
                Text("Make 2 sequences, in a 1v1 game")
                Text("Make 1 sequence, in a 1v1v1 game")
            }
            
            Section {
                VStack {
                    HStack {
                        VStack {
                            Spacer()
                            Text("Two Eyed Jacks")
                            Spacer()
                            Text("Remove other's coin")
                                .font(.system(size:13))
                        }
                        Spacer()
                        HStack {
                            CardView(card: Card(rank: .jack, suit: .clubs ), size : 80)
                            CardView(card: Card(rank: .jack, suit: .diamonds ), size :  80)
                        }
                    }
                    
                }
                VStack {
                    HStack {
                        VStack {
                            Spacer()
                            Text("One Eyed Jacks")
                            Spacer()
                            Text("Add your coin")
                                .font(.system(size:13))
                        }
                        Spacer()
                        HStack {
                            CardView(card: Card(rank: .jack, suit: .hearts ), size : 80)
                            CardView(card: Card(rank: .jack, suit: .spades ), size : 80)
                        }
                    }
                    
                }
                
            } header: {
                Text("Jacks have Special Powers")
            } footer: {
                Text("You can't remove coins that are part of a sequence You can add only to an Empty card")
            }
            
            Section {
                HStack{
                    Text("Can be used for your sequence ")
                    Spacer()
                    CardView(card: Card(coin:.special), size : 45)
                }
            } header: {
                Text("Corner Cards")
            }
        }
        
    }
        .navigationTitle("Rules")
    }
    
}

struct AllRulesViewPreviews: PreviewProvider {
    static var previews: some View {
        AllRules()
    }
}
