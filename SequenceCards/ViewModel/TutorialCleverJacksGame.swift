//
//  TutorialCleverJacksGame.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/16/23.
//


import Foundation

import SwiftUI

/// - Tag:CleverJacksGame
class TutorialCleverJacksGame: NSObject, ObservableObject {
    

    
    @Published var inSelectionCard : Card? = nil
    
    @Published var tutorial = false
    
    // The persistent game data.
    @Published var localParticipant: TutorialParticipant?
    
    @Published var myTurn = false

    @Published var board : Board?
    @Published var classicView: Bool = true
    
    @Published var cardCurrentlyPlayed : Card? = nil

    
    var boardCards: [[Card]] {
        board?.boardCards ?? Board(classicView: true, numberOfPlayers: 2).boardCards
    }
    
    /// The local player's name.
    var myName: String {
        localParticipant?.displayName ?? "You"
    }
    

    
    
    

    
    var myCards : [Card] {
        localParticipant?.data.cardsOnHand ?? []
    }
    
    
    
    func isItAValidSelectionCard(_ card: Card) -> Bool {
        if card.belongsToASequence {
            return false
        }
        else if card.coin == .special {
            return false
        }
        return  true
    }
    
    func startTutorialGame() {
        
        board = Board(tutorial: true)
        
        localParticipant = TutorialParticipant(displayName: "You", avatar: Image(systemName: "person.circle"))
        
        var localPlayerData = TutorialParticipant.PlayerGameData()
        localPlayerData.cardsOnHand = [Card(rank: .nine, suit: .spades ) , Card(rank: .queen , suit:.hearts) , Card(rank: .six, suit: .diamonds), Card(rank: .three, suit: .clubs) , Card(rank: .five, suit: .hearts)].shuffled()
        
        localPlayerData.coin = .blue
        localPlayerData.noOfSequences = 0
        localParticipant?.data = localPlayerData
        

    }
    
    
    
    
    func selectACard(_ card: Card) -> Card? {
        print("In selectACard")
        print("cardStack's count \(String(describing: board?.cardStack.count))")
        if !isItAValidSelectionCard(card) {
            
            return nil
            // throws an error saying card is already a part of sequence can't change it
        }
        guard let selectingCard = inSelectionCard, let index = board?.boardCards.indicesOf(x: card), let cardsOnHand = localParticipant?.data.cardsOnHand  else {
            print("Something is Wrong, Card should be in the range and selectingcard shouldn't be nill")
            return nil
            // throws an alert saying select a card
        }
        
        if !cardsOnHand.contains(selectingCard) {
           
            return nil
        }
        
        if let indexTobeRemoved = localParticipant?.data.cardsOnHand.firstIndex(of: selectingCard) {
            localParticipant?.data.cardsOnHand.remove(at: indexTobeRemoved)
            if let card = board?.cardStack.popLast() {
                print("Last Card from the stack the SelectACard\(card)")
                localParticipant?.data.cardsOnHand.append(card)
            }
            else {
                print("Something is Wrong")
                
                return nil
            }
        }
        else {
            
            return nil
        }
        
        if card.coin == nil {
            if myTurn {
                board?.boardCards[index.0][index.1].coin = localParticipant?.data.coin
            }// redo
            else {
                if localParticipant?.data.coin == .special {
                    print("Local Participant coin cannot be special")
                }
                print("Error")
            }
        }
        

        else {
            return nil
        }
        cardCurrentlyPlayed = selectingCard
        if let numberOfSequences = board?.getNumberOfSequences(index: index) {
            localParticipant?.data.noOfSequences +=  numberOfSequences
        }
        
        automaticTurn()
        print("Out SelectACard")
        return selectingCard
    }
    
    func automaticTurn() {
        
    }
    
    
    
    func canChooseThisCard(_ card: Card) -> Bool {
        guard let selectingCard = inSelectionCard else {
            return false
        }
        if card.belongsToASequence {
            return false
        }
        
        if selectingCard.isItATwoEyedJack && card.coin == nil   {
            return true
        }
        else if selectingCard.isItAOneEyedJack && card.coin != nil && card.coin != .special && card.coin != localParticipant?.data.coin {
            return true
        }
        return selectingCard.hasASameFaceAs(card) && card.coin == nil
    }
    
    
    
    /// Resets the game interface to the content view.
    func resetGame() {
        // Reset the game data.
        myTurn = false
        localParticipant?.data = TutorialParticipant.PlayerGameData()
        inSelectionCard = nil
        cardCurrentlyPlayed = nil
        board = nil
    }
    
    /// Authenticates the local player and registers for turn-based events.
    /// - Tag:authenticatePlayer
    
}

struct TutorialParticipant {
    var id = UUID()
    var displayName: String
    var avatar = Image(systemName: "person")
    var data = PlayerGameData()
    struct PlayerGameData : Codable {
        var cardsOnHand : [Card] = []
        var coin : Coin? = nil
        var noOfSequences = 0
        var turns = 0
    }
}
