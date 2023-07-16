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
    // The game interface state.
    @Published var playingGame = false
    
    @Published var inSelectionCard : Card? = nil
    
    
    @Published var isLoading = false
    
    // Outcomes of the game for notifing players.
    @Published var youWon = false
    @Published var youLost = false
    
    @Published var isGameOver = false
    
    // The match information.
    @Published var currentMatchID: String? = nil
    @Published var maxPlayers = 2
    @Published var minPlayers = 2
    
    // The persistent game data.
    @Published var localParticipant: TutorialParticipant?
    @Published var opponent: TutorialParticipant?
    @Published var opponent2: TutorialParticipant? = nil
    
    @Published var myTurn = false
    // Check if enum of local, player2, player3 solves this?
    
    
    var showDiscard : Bool {
        checkToDiscardtheCard(inSelectionCard)
    }
    
    @Published var board : Board?
    @Published var classicView: Bool = true
    
    @Published var cardCurrentlyPlayed : Card? = nil
    
    var numberOfPlayers : Int {
        board?.numberOfPlayers ?? minPlayers
    }
    
    var boardCards: [[Card]] {
        board?.boardCards ?? Board(classicView: true, numberOfPlayers: 2).boardCards
    }
    
    /// The local player's name.
    var myName: String {
        localParticipant?.displayName ?? "You"
    }
    
    /// The opponent's name.
    var opponentName: String {
        opponent?.displayName ?? "Opponent"
    }
    
    
    var sequencesChanged: Int = 0

    
    var opponentAvatar: Image {
        opponent?.avatar ?? Image(systemName: "person.crop.circle")
    }
    
    var opponent2Avatar: Image {
        opponent2?.avatar ?? Image(systemName: "person.crop.circle")
    }
    
    
    
    var myNoOfSequences : Int {
        get {localParticipant?.data.noOfSequences ?? 0}
        set {localParticipant?.data.noOfSequences = newValue}
    }
    
    var opponentNoOfSequences : Int {
        opponent?.data.noOfSequences ?? 0
    }
    
    var opponent2NoOfSequences : Int {
        opponent2?.data.noOfSequences ?? 0
    }
    
    
    var myCards : [Card] {
        localParticipant?.data.cardsOnHand ?? []
    }
    
    var myCoin : Coin? {
        localParticipant?.data.coin ?? .blue
    }
    var opponentCoin : Coin? {
        opponent?.data.coin ?? .green
    }
    
    var opponent2Coin : Coin? {
        opponent2?.data.coin ?? .red
    }
    
    var myTurns : Int {
        localParticipant?.data.turns ?? 0
    }
    
    var opponentTurns : Int {
        opponent?.data.turns ?? 0
    }
    
    var opponent2Turns : Int {
        opponent2?.data.turns ?? 0
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
        
        
        opponent = TutorialParticipant(displayName: "Opponent", avatar: Image(systemName: "person.circle"))
        var opponentPlayerData = TutorialParticipant.PlayerGameData()
        opponentPlayerData.cardsOnHand = (board?.dealCards(noOfCardsToDeal: 5))!
        opponentPlayerData.coin = .green
        opponentPlayerData.noOfSequences = 0
        opponent?.data = opponentPlayerData

    }
    
    func getTutorialDefaultCards(cardStack: [Card]?, index : Int) -> [Card] {
        guard var cardStack else {
            return [Card()]
        }
        var cards : [Card] = []
        for i in stride(from: 0 + index, to: 50, by: 7) {
            cards.append(cardStack[i])
            cardStack.remove(at: i)
        }
        return cards
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
        
        else if card.coin == opponent?.data.coin || card.coin == opponent2?.data.coin {
            if myTurn {
                board?.boardCards[index.0][index.1].coin = nil
            }
            else {
                print("Error")
            }
            
        }
        else {
            return nil
        }
        cardCurrentlyPlayed = selectingCard
        if let numberOfSequences = board?.getNumberOfSequences(index: index) {
            localParticipant?.data.noOfSequences +=  numberOfSequences
            sequencesChanged += numberOfSequences
        }
        
        automaticTurn()
        print("Out SelectACard")
        return selectingCard
    }
    
    func automaticTurn() {
        
    }
    
    
    func refresh() async {
        guard currentMatchID != nil else {
            playingGame = false
            isLoading = false
            return
        }
            isLoading = false
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
    
    func checkToDiscardtheCard(_ card: Card?) -> Bool {
        guard let discardableCard = card else {
            return false
        }
        if discardableCard.isItATwoEyedJack || discardableCard.isItAOneEyedJack {
            return false
        }
        if let numberOfCardsLeft = board?.numberOfSelectableCardsLeftInTheBoard(discardableCard) {
            print(numberOfCardsLeft)
            if numberOfCardsLeft == 0 {
                return true
            }
        }
        return false
    }
    
    func discardTheCard() {
        if let selectingCard = inSelectionCard {
            if checkToDiscardtheCard(selectingCard) {
                if let indexTobeRemoved = localParticipant?.data.cardsOnHand.firstIndex(of: selectingCard) {
                    localParticipant?.data.cardsOnHand.remove(at: indexTobeRemoved)
                    if let card = board?.cardStack.popLast() {
                        print("Last Card from the stack the SelectACard\(card)")
                        localParticipant?.data.cardsOnHand.append(card)
                    }
                    else {
                        print("Something is Wrong")
                       
                    }
                }
            }
        }
    }
    
    
    /// Resets the game interface to the content view.
    func resetGame() {
        // Reset the game data.
        
        playingGame = false
        youWon = false
        youLost = false
        isGameOver = false
        myTurn = false
        localParticipant?.data = TutorialParticipant.PlayerGameData()
        opponent = nil
        opponent2 = nil
        currentMatchID = nil
        inSelectionCard = nil
        cardCurrentlyPlayed = nil
        board = nil
        sequencesChanged = 0
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
