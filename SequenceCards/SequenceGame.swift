//
//  SequenceGame.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

@preconcurrency import GameKit
import SwiftUI


/// - Tag:SequenceGame
@MainActor class SequenceGame: NSObject, GKMatchDelegate, GKLocalPlayerListener, ObservableObject {
    // The game interface state.
    @Published var matchAvailable = false
    @Published var playingGame = false
    @Published var myTurn = false
    @Published var inSelectionCard : Card? = nil
    
    // Outcomes of the game for notifing players.
    @Published var youWon = false
    @Published var youLost = false
    

    
    // The match information.
    @Published var currentMatchID: String? = nil
    @Published var maxPlayers = 2
    @Published var minPlayers = 2
    
    // The persistent game data.
    @Published var localParticipant: Participant? = nil
    @Published var opponent: Participant? = nil
    @Published var count = 0
    @Published var noOfCardsToDeal = 6
    // The messages between players.
    var messages: [Message] = []
    @Published var matchMessage: String? = nil
    
    @Published var board : Board? = nil
    
    @Published var cardCurrentlyPlayed : Card? = nil
    
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
    
    /// The opponent's name.
    var opponentName: String {
        opponent?.player.displayName ?? "Opponent"
    }
    
    /// The local player's avatar image.
    var myAvatar: Image {
        localParticipant?.avatar ?? Image(systemName: "person.crop.circle")
    }
    
    /// The opponent's avatar image.
    var opponentAvatar: Image {
        opponent?.avatar ?? Image(systemName: "person.crop.circle")
    }
    

    var myNoOfSequences : Int {
        get { localParticipant?.noOfSequences ?? 0 }
        set { localParticipant?.noOfSequences = newValue}
    }
    
    var opponentNoOfSequences : Int {
        get { opponent?.noOfSequences ?? 0 }
        set { opponent?.noOfSequences = newValue }
    }
    
    var myCards : [Card] {
        get { localParticipant?.cardsOnHand ?? [] }
        set { localParticipant?.cardsOnHand = newValue }
    }
    
    var myCoin : Coin? {
        get { localParticipant?.coin }
        set { localParticipant?.coin = newValue }
    }
    var opponentCoin : Coin? {
        get { opponent?.coin ?? .special }
        set { opponent?.coin = newValue }
    }
        
    /// The root view controller of the window.
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    
    func selectACard(_ card: Card) -> Int { // Refactor
        print("Local Player \(localParticipant?.player.displayName ?? "SomeName")")
        print("Opponent Player \(opponent?.player.displayName ?? "SomeOtherName")")
        
        print("localParticipant' coin \(localParticipant?.coin ?? .special) ")
        print("Opponents' coin \(opponent?.coin ?? .special) ")
        if card.belongsToASequence || card.coin == .special {
            print("Something is Wrong, Coin shouldn't be Special")
            return 0
            // throws an error saying card is already a part of sequence can't change it
        }
        
        guard let selectingCard = inSelectionCard, let index = board?.boardCards.indicesOf(x: card)  else {
            print("Something is Wrong, Card should be in the range and selectingcard shouldn't be nill")
            return 0
            // throws an alert saying select a card
        }
        
        if card.coin == nil {
            if myTurn {
                board?.boardCards[index.0][index.1].coin = localParticipant?.coin
                
            }// redo
            else {
                board?.boardCards[index.0][index.1].coin = opponent?.coin
            }
        }
        
        else if card.coin == opponent?.coin {
            board?.boardCards[index.0][index.1].coin = nil
            
        }
        else {
            return 0
        }
        
        if let indexTobeRemoved = (localParticipant?.cardsOnHand.firstIndex(of: selectingCard)) {
            localParticipant?.cardsOnHand.remove(at: indexTobeRemoved)
            if let card = board?.cardStack.popLast() {
                localParticipant?.cardsOnHand.append(card)
            }
        }
        cardCurrentlyPlayed = selectingCard
        localParticipant?.noOfSequences += board?.getNumberOfSequences(index: index) ?? 0
        if localParticipant?.noOfSequences == 2 {
            youWon = true
        }
        Task {
            await takeTurn()
        }
        return 1
    }
    
    func refresh() async {
        guard currentMatchID != nil && myTurn == false else { return }
        do {
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            if myTurn == false {
                myTurn = GKLocalPlayer.local == match.currentParticipant?.player ? true : false
                decodeGameData(matchData: match.matchData!)
            }
        }
        catch {
            print("Took a lot of time for loading")
            print("Error: \(error.localizedDescription).")
        }
    }
    func canChooseThisCard(_ card: Card) -> Bool {
        guard let selectingCard = inSelectionCard else {
            return false
        }
        if card.belongsToASequence {
            return false
        }
        
        if selectingCard.isASpecialCard   {
            if card.coin == nil && (selectingCard.suit == .diamonds || selectingCard.suit == .hearts){
                return true
            }
            else if card.coin != nil && card.coin != .special && card.coin != localParticipant?.coin && (selectingCard.suit == .clubs || selectingCard.suit == .spades) {
                return true
            }
            else {
                return false
            }
        }
        return selectingCard.rank == card.rank && selectingCard.suit == card.suit && card.coin == nil
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /// Resets the game interface to the content view.
    func resetGame() {
        // Reset the game data.
        playingGame = false
        myTurn = false
        currentMatchID = nil
        opponent = nil
        count = 0
        board = nil
        cardCurrentlyPlayed = nil
        youWon = false
        youLost = false
        myCoin = nil
        opponentCoin = nil
        myCards = []
        myNoOfSequences = 0
    }
    
    /// Authenticates the local player and registers for turn-based events.
    /// - Tag:authenticatePlayer
    func authenticatePlayer() {
        // Set the authentication handler that GameKit invokes.
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // If the view controller is non-nil, present it to the player so they can
                // perform some necessary action to complete authentication.
                self.rootViewController?.present(viewController, animated: true) { }
                return
            }
            if let error {
                // If you can’t authenticate the player, disable Game Center features in your game.
                print("Error: \(error.localizedDescription).")
                return
            }
            
            // A value of nil for viewController indicates successful authentication, and you can access
            // local player properties.
            
            // Load the local player's avatar.
            GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                if let image {
                    // Create a Participant object to store the local player data.
                    self.localParticipant = Participant(player: GKLocalPlayer.local,
                                                        avatar: Image(uiImage: image))
                    
                }
                if let error {
                    // Handle an error if it occurs.
                    print("Error: \(error.localizedDescription).")
                }
            }
            
            // Register for turn-based invitations and other events.
            GKLocalPlayer.local.register(self)
            
            // Enable the Start Game button.
            self.matchAvailable = true
        }
    }
    
    /// Presents the turn-based matchmaker interface where the local player selects players and takes the first turn.
    ///
    /// Handles when the player initiates a match in the game and using Game Center.
    /// - Parameter playersToInvite: The players that the local player wants to invite.
    /// Provide this parameter when the player has selected players using Game Center.
    ///- Tag:startMatch
    func startMatch(_ playersToInvite: [GKPlayer]? = nil) {
        // Initialize the match data.
        count = 0
        print("StartMatch is Called.")
        board = Board()
        
        // Create a match request.
        // may not require a seed if we send in the entire board.
        // add all the necessary functions somewhere here
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        if playersToInvite != nil {
            request.recipients = playersToInvite
        }
        
        // Present the interface where the player selects opponents and starts the game.
        let viewController = GKTurnBasedMatchmakerViewController(matchRequest: request)
        viewController.turnBasedMatchmakerDelegate = self
        rootViewController?.present(viewController, animated: true) { }
    }
    
    /// Removes all the matches from Game Center.
    func removeMatches() async {
        do {
            // Load all the matches.
            let existingMatches = try await GKTurnBasedMatch.loadMatches()
            
            // Remove all the matches.
            for match in existingMatches {
                try await match.remove()
            }
        } catch {
            print("Error: \(error.localizedDescription).")
        }
        
    }
    
    /// Takes the local player's turn.
    /// - Tag:takeTurn
    func takeTurn() async {
        // Handle all the cases that can occur when the player takes their turn:
        // 1. Resets the interface if GameKit fails to load the match.
        // 2. Ends the game if there aren't enough players.
        // 3. Otherwise, takes the turn and passes to the next participant.
        
        // Check whether there's an ongoing match.
        guard currentMatchID != nil else { return }
        
        do {
            // Load the most recent match object from the match ID.
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            
            // Remove participants who quit or otherwise aren't in the match.
            let activeParticipants = match.participants.filter {
                $0.status != .done
            }
            
            // End the match if the active participants drop below the minimum. Only the current
            // participant can end a match, so check for this condition in this method when it
            // becomes the local player's turn.
            if activeParticipants.count < minPlayers {
                // Set the match outcomes for active participants.
                for participant in activeParticipants {
                    participant.matchOutcome = .won
                }
                
                // End the match in turn.
                try await match.endMatchInTurn(withMatch: match.matchData!)
                
                // Notify the local player when the match ends.
                youWon = true
            } else {
                // Otherwise, take the turn and pass to the next participants.
                
                // Update the game data.
                count += 1
                
                // *** UPDATE THE BOARD ****
                // Create the game data to store in Game Center.
                let gameData = (encodeGameData() ?? match.matchData)!
                
                if youWon == true {
                    match.currentParticipant?.matchOutcome = .won
                    let nextParticipants = activeParticipants.filter {
                        $0 != match.currentParticipant
                    }
                    for participant in nextParticipants {
                        participant.matchOutcome = .lost
                    }

                }
                
                for participant in activeParticipants {
                    print("Name \(String(describing: participant.player?.displayName))")
                    print("Outcome \(participant.matchOutcome)")
                    print("Status \(participant.status)")
                }
                
                
                
                // Remove the current participant from the match participants.
                let nextParticipants = activeParticipants.filter {
                    $0 != match.currentParticipant
                }
                

                
                
                // Set the match message.
                match.setLocalizableMessageWithKey( myTurn ? "Your Turn" : "Opponents Turn", arguments: nil)
                
                // Save any exchanges.
                saveExchanges(for: match)
                
                // Pass the turn to the next participant.
                try await match.endTurn(withNextParticipants: nextParticipants, turnTimeout: GKTurnTimeoutDefault,
                                        match: gameData)
                
                myTurn = false
            }
        } catch {
            // Handle the error.
            print("Error: \(error.localizedDescription).")
            resetGame()
        }
    }
    
    /// Quits the game by forfeiting the match.
    /// - Tag:forfeitMatch
    func forfeitMatch() async {
        // Check whether there's an ongoing match.
        guard currentMatchID != nil else { return }
        
        do {
            // Load the most recent match object from the match ID.
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            
            // Forfeit the match while it's the local player's turn.
            if myTurn {
                // The game updates the data when turn-based events occur, so this game instance should
                // have the current data.
                
                // Create the game data to store in Game Center.
                let gameData = (encodeGameData() ?? match.matchData)!
                
                // Remove the participants who quit and the current participant.
                let nextParticipants = match.participants.filter {
                    ($0.status != .done) && ($0 != match.currentParticipant)
                }
                
                // Forfeit the match.
                try await match.participantQuitInTurn(
                    with: GKTurnBasedMatch.Outcome.quit,
                    nextParticipants: nextParticipants,
                    turnTimeout: GKTurnTimeoutDefault,
                    match: gameData)
                
                // Notify the local player that they forfeit the match.
                youLost = true
            } else {
                // Forfeit the match while it's not the local player's turn.
                try await match.participantQuitOutOfTurn(with: GKTurnBasedMatch.Outcome.quit)
                
                // Notify the local player that they forfeit the match.
                youLost = true
            }
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    /// Sends a reminder to the opponent to take their turn.
    func sendReminder() async {
        // Check whether there's an ongoing match.
        guard currentMatchID != nil else { return }
        
        do {
            // Load the most recent match object from the match ID.
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            
            // Create an array containing the current participant.
            let participants = match.participants.filter {
                $0 == match.currentParticipant
            }
            
            // Send a reminder to the current participant.
            try await match.sendReminder(to: participants, localizableMessageKey: "This is a sendReminder message.",
                                         arguments: [])
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
    
    /// Ends the match without forfeiting the game.
    func quitGame() {
        resetGame()
    }
    
    /// Sends a message from one player to another.
    ///
    /// - Parameter content: The message to send to the other player.
    /// - Tag:sendMessage
    func sendMessage(content: String) async {
        // Check whether there's an ongoing match.
        guard currentMatchID != nil else { return }
        
        // Create a message instance to display in the message view.
        let message = Message(content: content, playerName: GKLocalPlayer.local.displayName,
                              isLocalPlayer: true)
        messages.append(message)
        
        do {
            // Create the exchange data.
            guard let data = content.data(using: .utf8) else { return }
            
            // Load the most recent match object from the match ID.
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            
            // Remove the local player (the sender) from the recipients;
            // otherwise, GameKit doesn't send the exchange request.
            let participants = match.participants.filter {
                localParticipant?.player.displayName != $0.player?.displayName
            }
            
            // Send the exchange request with the message.
            try await match.sendExchange(to: participants, data: data,
                                         localizableMessageKey: "This is my text message.",
                                         arguments: [], timeout: GKTurnTimeoutDefault)
        } catch {
            print("Error: \(error.localizedDescription).")
            return
        }
    }
    
    /// Exchange an item.
    func exchangeItem() async {
        // Check whether there's an ongoing match.
        guard currentMatchID != nil else { return }
        
        do {
            // Load the most recent match object from the match ID.
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            
            // Remove the local player (the sender) from the recipients; otherwise, GameKit doesn't send
            // the exchange request.
            let participants = match.participants.filter {
                self.localParticipant?.player.displayName != $0.player?.displayName
            }
            
            // Send the exchange request with the message.
            try await match.sendExchange(to: participants, data: Data(),
                                         localizableMessageKey: "This is my exchange item request.",
                                         arguments: [], timeout: GKTurnTimeoutDefault)
        } catch {
            print("Error: \(error.localizedDescription).")
            return
        }
    }
}
