//
//  CleverJacksGame.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

@preconcurrency import GameKit
import SwiftUI

/// - Tag:CleverJacksGame
@MainActor class CleverJacksGame: NSObject, GKMatchDelegate, GKLocalPlayerListener, ObservableObject {
    // The game interface state.
    @Published var matchAvailable = false
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
    @Published var localParticipant: Participant? = nil
    @Published var opponent: Participant? = nil
    @Published var opponent2: Participant? = nil
    
    @Published var myTurn = false
    @Published var whichPlayersTurn: GKPlayer? = nil
    // Check if enum of local, player2, player3 solves this?
    
    @Published var noOfCardsToDeal = 6
    // The messages between players.
    //    var messages: [Message] = []
    @Published var messages: [Message] = []
    @Published var unViewedMessages : [Message] = []
    @Published var showMessages: Bool = false
    @Published var matchMessage: String? = nil
    
    var showDiscard : Bool {
        checkToDiscardtheCard(inSelectionCard)
    }
    
    @Published var board : Board? = nil
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
        GKLocalPlayer.local.displayName
    }
    
    /// The opponent's name.
    var opponentName: String {
        opponent?.player.displayName ?? "Opponent"
    }
    
    var opponent2Name : String {
        opponent2?.player.displayName ?? "Opponent2"
    }
    
    /// The local player's avatar image.
    var myAvatar: Image {
        localParticipant?.avatar ?? Image(systemName: "person.crop.circle")
    }
    
    /// The opponent's avatar image.
    var opponentAvatar: Image {
        opponent?.avatar ?? Image(systemName: "person.crop.circle")
    }
    
    var opponent2Avatar: Image {
        opponent2?.avatar ?? Image(systemName: "person.crop.circle")
    }
    
    var sequencesChanged: Int = 0
    
    
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
    
    
    /// The root view controller of the window.
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
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
    
    
    
    func selectACard(_ card: Card) -> Card? {
        print("In selectACard")
        print("cardStack's count \(String(describing: board?.cardStack.count))")
        if !isItAValidSelectionCard(card) {
            matchMessage = "Invalid Card"
            return nil
            // throws an error saying card is already a part of sequence can't change it
        }
        guard let selectingCard = inSelectionCard, let index = board?.boardCards.indicesOf(x: card), let cardsOnHand = localParticipant?.data.cardsOnHand  else {
            print("Something is Wrong, Card should be in the range and selectingcard shouldn't be nill")
            return nil
            // throws an alert saying select a card
        }
        
        if !cardsOnHand.contains(selectingCard) {
            matchMessage = "Try Again"
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
                matchMessage = "Match Tied"
                return nil
            }
        }
        else {
            matchMessage = "Try Again"
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
        
        Task {
            await takeTurn()
        }
        print("Out SelectACard")
        return selectingCard
    }
    
    func refresh() async {
        guard currentMatchID != nil else {
            playingGame = false
            isLoading = false
            return
        }
        do {
            let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
            if match.participants.firstIndex(where: {$0.status != .active || $0.status != .done}) != nil {
                matchMessage = "Waiting for all players"
            }
            if myTurn == false && localParticipant?.data.coin != nil {
                if let whichPlayersTurn = match.currentParticipant?.player {
                    self.whichPlayersTurn = whichPlayersTurn
                }
                if whichPlayersTurn == localParticipant?.player  {
                    matchMessage = "Waiting Server Response"
                }
            }
            decodeGameData(matchData: match.matchData!)
            isLoading = false
        }
        catch {
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
                        matchMessage = "Match Tied"
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
        localParticipant?.data = Participant.PlayerGameData()
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
        
        print("StartMatch is Called.")
        resetGame()
        board = Board(classicView: classicView, numberOfPlayers: minPlayers)
        // Create a match request.
        // add all the necessary functions somewhere here
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = minPlayers
        
        /// MAJOR CHECK UP CHANGED MINPLAYERS
        if playersToInvite != nil {
            request.recipients = playersToInvite
        }
        
        //        print("No Of Players \(minPlayers)")
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
                if match.status == .open {
                    // Forfeit the match while it's the local player's turn.
                    if match.currentParticipant?.player == localParticipant?.player {
                        // The game updates the data when turn-based events occur, so this game instance should
                        // have the current data.
                        // Create the game data to store in Game Center.
                        let gameData = (encodeGameData() ?? match.matchData)!
                        // Remove the participants who quit and the current participant.
                        let nextParticipants = match.participants.filter {
                            ($0.status != .done) && ($0 != match.currentParticipant)
                        }
                        // Forfeit the match.
                        if nextParticipants.count > 0 {
                            try await match.participantQuitInTurn(
                                with: GKTurnBasedMatch.Outcome.quit,
                                nextParticipants: nextParticipants,
                                turnTimeout: GKTurnTimeoutDefault,
                                match: gameData)
                        }
                        else {
                            match.currentParticipant?.matchOutcome = .won
                            try await match.endMatchInTurn(withMatch: match.matchData!)
                        }
                    } else {
                        // Forfeit the match while it's not the local player's turn.
                        try await match.participantQuitOutOfTurn(with: GKTurnBasedMatch.Outcome.quit)
                        
                    }
                    
                    
                }
                try await match.remove()
            }
        } catch {
            print("Error: \(error.localizedDescription).")
            print("Retrying")
            do {
                let existingMatches = try await GKTurnBasedMatch.loadMatches()
                for match in existingMatches {
                    try await match.remove()
                }
                print("Retry sucessful")
            }
            catch {
                print("Retried Error: \(error.localizedDescription).")
                print("Retry Failed Due to Game Center Response")
            }
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
            
            print("Active Participants \(activeParticipants.count)")
            
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
                isGameOver = true
            } else {
                // Otherwise, take the turn and pass to the next participants.
                
                // Update the game data.
                localParticipant?.data.turns += 1
                
                // Can't use here because the cards has to be selected for you to take turn and turn can be taken only after selection
                // Can't put it in selection, have to put it before selection.
                
                // *** UPDATE THE BOARD ****
                // Create the game data to store in Game Center.
                let gameData = (encodeGameData() ?? match.matchData)!
                var nextParticipants : [GKTurnBasedParticipant] = []
                
                // Remove the current participant from the matech participants.
                if let nextParticipantIndex = activeParticipants.firstIndex(where: {
                    $0 == match.currentParticipant
                }) {
                    nextParticipants = Array(activeParticipants[(nextParticipantIndex+1)...]) + Array(activeParticipants[..<nextParticipantIndex])
                }
                else {
                    print("Something is Wrong")
                }
                
                //                nextParticipants.sort() {
                //                    if let firstTurnDate = $0.lastTurnDate, let secondTurnDate = $1.lastTurnDate {
                //                        return firstTurnDate < secondTurnDate
                //                    }
                //                    return $0.status.rawValue < $1.status.rawValue
                //                }
                
                for participant in nextParticipants {
                    print("Status \(participant.status)")
                    print("Name \(String(describing: participant.player?.displayName))")
                    print("Date \(String(describing: participant.lastTurnDate))")
                }
                
                
                if let requiredNoOfSequences = board?.requiredNoOfSequences {
                    if localParticipant?.data.noOfSequences == requiredNoOfSequences {
                        match.currentParticipant?.matchOutcome = .won
                        for participant in nextParticipants {
                            participant.matchOutcome = .lost
                        }
                        try await match.endMatchInTurn(withMatch: gameData)
                        youWon = true
                        isGameOver = true
                        print("Whats Happening")
                    }
                }
                else if board?.cardStack.count == 0 {
                    match.currentParticipant?.matchOutcome = .tied
                    for participant in nextParticipants {
                        participant.matchOutcome = .tied
                    }
                    try await match.endMatchInTurn(withMatch: gameData)
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
            print("Is there an error after winning.")
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
                if nextParticipants.count > 0 {
                    try await match.participantQuitInTurn(
                        with: GKTurnBasedMatch.Outcome.quit,
                        nextParticipants: nextParticipants,
                        turnTimeout: GKTurnTimeoutDefault,
                        match: gameData)
                    youLost = true
                    isGameOver = true
                }
                else {
                    match.currentParticipant?.matchOutcome = .won
                    try await match.endMatchInTurn(withMatch: match.matchData!)
                    youWon = true
                    isGameOver = true
                    
                }
                
                // Notify the local player that they forfeit the match.
                
            } else {
                // Forfeit the match while it's not the local player's turn.
                try await match.participantQuitOutOfTurn(with: GKTurnBasedMatch.Outcome.quit)
                
                // Notify the local player that they forfeit the match.
                youLost = true
                isGameOver = true
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
            if match.currentParticipant?.player != localParticipant?.player {
                
                // Send a reminder to the current participant.
                try await match.sendReminder(to: participants, localizableMessageKey: "\(myName) reminded you",
                                             arguments: [])
            }
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
        guard currentMatchID != nil else {
            
            print("returning from sendMessage as CurrentMatchId is nil")
            return
        }
        
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

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
