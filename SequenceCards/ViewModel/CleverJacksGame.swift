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
    @Published var auto = false
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
    
    var lastPlayedBy = ""
    // Check if enum of local, player2, player3 solves this?
    @Published var noOfCardsToDeal = 6
    // The messages between players.
    //    var messages: [Message] = []
    @Published var messages: [Message] = []
    @Published var unViewedMessages : [Message] = []
    @Published var showMessages: Bool = false
    @Published var matchMessage: String? = nil
    @Published var showDiscard : Bool = false
    
    @Published var board : Board? = nil
    @Published var classicView: Bool = true
    
    @Published var cardCurrentlyPlayed : Card? = nil
    @Published var cardRecentlyChanged : Card? = nil
    
    
    @Published var refreshedTime = 0
    var playerTaskIsRunning = 0
    var numberOfPlayers : Int {
        board?.numberOfPlayers ?? minPlayers
    }
    
    var boardCards: [[Card]] {
        board?.boardCards ?? Board(classicView: true, numberOfPlayers: 2).boardCards
    }
    
    @Published var allOpenMatches : [GKTurnBasedMatch] = []
    var allCompletedMatches : [GKTurnBasedMatch] = []
    
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
        get {localParticipant?.data?.noOfSequences ?? 0}
        set {localParticipant?.data?.noOfSequences = newValue}
    }
    
    var opponentNoOfSequences : Int {
        opponent?.data?.noOfSequences ?? 0
    }
    
    var opponent2NoOfSequences : Int {
        opponent2?.data?.noOfSequences ?? 0
    }
    
    
    var myCards : [Card] {
        localParticipant?.data?.cardsOnHand ?? []
    }
    
    var myCoin : Coin? {
        localParticipant?.data?.coin ?? .blue
    }
    var opponentCoin : Coin? {
        opponent?.data?.coin ?? .green
    }
    
    var opponent2Coin : Coin? {
        opponent2?.data?.coin ?? .red
    }
    

    /// The root view controller of the window.
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    
    
    func selectACard(_ card: Card) -> Card? {
        guard let selectingCard = inSelectionCard, let index = board?.boardCards.indicesOf(x: card), let cardsOnHand = localParticipant?.data?.cardsOnHand  else {
            matchMessage = "Try Again"
            return nil
            // throws an alert saying select a card
        }
        
        if !cardsOnHand.contains(selectingCard) {
            matchMessage = "Card unavailable"
            return nil
        }
        

        
        if card.coin == nil {
            board?.boardCards[index.0][index.1].coin = localParticipant?.data?.coin
        }
        
        else if ( card.coin == opponent?.data?.coin || card.coin == opponent2?.data?.coin ) && card.coin != .special {
            board?.boardCards[index.0][index.1].coin = nil
        }
        else {
            return nil
        }
        
        cardRecentlyChanged = board?.boardCards[index.0][index.1]
        
        if let indexTobeRemoved = cardsOnHand.firstIndex(of: selectingCard) {
            localParticipant?.data?.cardsOnHand.remove(at: indexTobeRemoved)
            cardCurrentlyPlayed = selectingCard
            if let card = board?.cardStack.popLast() {
                localParticipant?.data?.cardsOnHand.append(card)
            }
        }
        else {
            matchMessage = "Match Tied"
            // Send this information
            return nil
        }
        

        
        if let numberOfSequences = board?.getNumberOfSequences(index: index) {
            localParticipant?.data?.noOfSequences +=  numberOfSequences
            sequencesChanged += numberOfSequences
        }
        
        
        if auto == true {
            myTurn = false
            if localParticipant?.data?.noOfSequences ?? 0 >= 2 {
                localParticipant?.data?.result = .won
                opponent?.data?.result = .lost
                youWon = true
                isGameOver = true
            }
            if let encoded = encodeGameData()  {
                print("Encoding")
                UserDefaults.standard.set(encoded, forKey: "AutoMatch")
            }
            return selectingCard
        }
        else {
            Task {
                await takeTurn()
            }
        }
        return selectingCard
    }
    
    
    func canChooseThisCard(_ card: Card) -> Bool {
        guard let selectingCard = inSelectionCard else {
            return false
        }
        if card.belongsToASequence && card.coin == .special {
            return false
        }
        
        if selectingCard.isItATwoEyedJack && card.coin == nil   {
            return true
        }
        else if selectingCard.isItAOneEyedJack && card.coin != nil && card.coin != .special && card.coin != localParticipant?.data?.coin {
            return true
        }
        return selectingCard.hasASameFaceAs(card) && card.coin == nil
    }
    
    func checkToDiscardtheCard(_ card: Card?) -> Bool {
        guard let discardableCard = card else {
            showDiscard = false
            return false
        }
        if discardableCard.isItATwoEyedJack || discardableCard.isItAOneEyedJack {
            showDiscard = false
            return false
        }
        if let numberOfCardsLeft = board?.numberOfSelectableCardsLeftInTheBoard(discardableCard) {
            if numberOfCardsLeft == 0 {
                showDiscard = true
                return true
            }
        }
        showDiscard = false
        return false
    }
    
    func discardTheCard() {
        if let selectingCard = inSelectionCard {
            if checkToDiscardtheCard(selectingCard) {
                if let indexTobeRemoved = localParticipant?.data?.cardsOnHand.firstIndex(of: selectingCard) {
                    localParticipant?.data?.cardsOnHand.remove(at: indexTobeRemoved)
                    if let card = board?.cardStack.popLast() {
                        localParticipant?.data?.cardsOnHand.append(card)
                    }
                    else {
                        print("Something is Wrong")
                        matchMessage = "Match Tied"
                    }
                }
            }
        }
    }
    
    
    func refresh() {

        guard currentMatchID != nil else {
            resetGame()
            return
        }
        Task {
            do {
                let match = try await GKTurnBasedMatch.load(withID: currentMatchID!)
                if let index =  match.participants.firstIndex(where: {$0.status != .active && $0.status != .done}) {
                    matchMessage = "Waiting for all players "
                    print("Player \(String(describing: match.participants[index].player?.displayName))")
                }
                if myTurn == false && localParticipant?.data?.coin != nil {
                    if let whichPlayersTurn = match.currentParticipant?.player {
                        self.whichPlayersTurn = whichPlayersTurn
                    }
                    if whichPlayersTurn == localParticipant?.player {
                        if matchMessage == "Waiting Server Response" {
                            if playerTaskIsRunning == 0 {
                                playerTaskIsRunning += 1
                                decodeGameData(matchData: match.matchData!)
                                myTurn = true
                                matchMessage = "Refreshed"
                            }
                            else {
                                matchMessage = "Click again to Force Refresh"
                            }
                        }
                        else if matchMessage == "Click again to Force Refresh" {
                            if myTurn == false {
                                resetGame()
                            }
                        }
                        else {
                            matchMessage = "Waiting Server Response"
                        }
                    }
                    else {
                        decodeGameData(matchData: match.matchData!)
                    }
                }
                isLoading = false
            }
            catch {
                print("Error: \(error.localizedDescription).")
            }
            print("REFRESH TASK DONE")
        }
        refreshedTime += 1
    }
    
    
    /// Resets the game interface to the content view.
    func resetGame() {
        // Reset the game data.
        playerTaskIsRunning = 0
        refreshedTime = 0
        auto = false
        playingGame = false
        youWon = false
        youLost = false
        isGameOver = false
        myTurn = false
        localParticipant?.data = nil
        opponent = nil
        opponent2 = nil
        currentMatchID = nil
        inSelectionCard = nil
        cardCurrentlyPlayed = nil
        board = nil
        sequencesChanged = 0
        lastPlayedBy = ""
        whichPlayersTurn = nil
        
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
                
                
                // For Testing
                if let requiredNoOfSequences = board?.requiredNoOfSequences, let localPlayerSequences =  localParticipant?.data?.noOfSequences{
                    if localPlayerSequences >= requiredNoOfSequences {
                        match.currentParticipant?.matchOutcome = .won
                        for participant in nextParticipants {
                            participant.matchOutcome = .lost
                        }
                        try await match.endMatchInTurn(withMatch: gameData)
                        youWon = true
                        isGameOver = true
                        return
                    }
                }
                if board?.cardStack.count == 0 && !isGameOver {
                    match.currentParticipant?.matchOutcome = .tied
                    for participant in nextParticipants {
                        participant.matchOutcome = .tied
                    }
                    try await match.endMatchInTurn(withMatch: gameData)
                }
                
                // Set the match message.
                
                match.setLocalizableMessageWithKey( myTurn ? "Next Turn" : "", arguments: nil)
                
                // Save any exchanges.
                saveExchanges(for: match)
                if isGameOver == false {
                    // Pass the turn to the next participant.
                    try await match.endTurn(withNextParticipants: nextParticipants, turnTimeout: GKTurnTimeoutDefault,
                                            match: gameData)
                }
                
                myTurn = false
            }
        } catch {
            // Handle the error.
            print("Error: \(error.localizedDescription).")
            print("Is there an error after winning.")
            resetGame()
        }
    }
    
    
    func getTheListOfAllAvailableOpenMatches() async  {
        allOpenMatches = []
        print("Getting")
        if localParticipant == nil {
            return
        }
        guard let existingMatches = try? await GKTurnBasedMatch.loadMatches() else {
            print("Couldn't")
            allOpenMatches = []
            return 
        }
        print("Got")
        
        allOpenMatches = existingMatches.filter { $0.status == .open }
        print("Got \(allOpenMatches)")
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
                                         localizableMessageKey: "\(myName) sent a message.",
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
    
    
    func selectACardByOpponent(_ card: Card, selectingCard : Card?) -> Card? {
        print("Selecting Card \(String(describing: selectingCard))")
        guard let selectingCard, let index = board?.boardCards.indicesOf(x: card), let opponentsCards = opponent?.data?.cardsOnHand  else {
            matchMessage = "Try Again"
            return nil
            // throws an alert saying select a card
        }


        
        if let indexTobeRemoved = opponent?.data?.cardsOnHand.firstIndex(of: selectingCard) {
            opponent?.data?.cardsOnHand.remove(at: indexTobeRemoved)
            if let card = board?.cardStack.popLast() {
                print("Card \(card)")
                print("count \(board!.cardStack.count)")
                opponent?.data?.cardsOnHand.append(card)
            }
            else {
                matchMessage = "Match Tied"
                return nil
            }
        }
        else {
            print(opponentsCards, selectingCard)
            matchMessage = "Card is not available"
            return nil
        }
        
        if card.coin == nil {
            board?.boardCards[index.0][index.1].coin = .green
        }
        
        else if  card.coin == localParticipant?.data?.coin && card.coin != .special  {
            board?.boardCards[index.0][index.1].coin = nil
        }
        else {
            matchMessage = "Wrong Selection"
            
            return nil
        }


        cardCurrentlyPlayed = selectingCard
        cardRecentlyChanged = board?.boardCards[index.0][index.1]
        if let numberOfSequences = board?.getNumberOfSequences(index: index) {
            opponent?.data?.noOfSequences +=  numberOfSequences
            sequencesChanged += numberOfSequences
            if opponent?.data?.noOfSequences ?? 0 > 1 {
                youLost = true
                isGameOver = true
                myTurn = false
                opponent?.data?.result = .won
                localParticipant?.data?.result = .lost
                if let encoded = encodeGameData()  {
                    print("Encoding")
                    UserDefaults.standard.set(encoded, forKey: "AutoMatch")
                }
                return selectingCard
            }
        }
        
        myTurn = true
        if let encoded = encodeGameData()  {
            print("Encoding")
            UserDefaults.standard.set(encoded, forKey: "AutoMatch")
        }
        print(selectingCard)
        
        return selectingCard
    }
    
    
    func startAutoGame(newGame: Bool = false) {
        var newMatch = newGame
        playingGame = true
        opponent = Participant(player: GKPlayer())
        opponent?.isABot = true
        
        if let data = UserDefaults.standard.data(forKey: "AutoMatch") {
            decodeGameData(matchData: data)
            if let opponentData = opponent?.data {
                if opponentData.result == .won || opponentData.result == .lost {
                    newMatch = true
                }
            }
            else {
                newMatch = true
            }
        }
        else {
            newMatch = true
        }
        if newMatch {
            board = Board(classicView: true, numberOfPlayers: 2)
            inSelectionCard = nil
            let localCardsOnHand = (board?.dealCards(noOfCardsToDeal: 5))!
            localParticipant?.data = Participant.PlayerGameData(cardsOnHand: localCardsOnHand, coin: .blue, currentMatchID: "AutoMatch")
            let opponentsCardsOnHand = (board?.dealCards(noOfCardsToDeal: 8))!
            opponent?.data = Participant.PlayerGameData(cardsOnHand: opponentsCardsOnHand, coin: .green, currentMatchID: "AutoMatch")
            
        }
        myTurn = true
    }
     func delayAutomaticTurn() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
    }
    
    func automaticTurn() {
        // Check 5 cards on all sides and if the card is available then put it there
        Task {
            guard let opponentCards = opponent?.data?.cardsOnHand, let currentBoardCards = board?.boardCards else { return }
            print(opponentCards)
            print("To Add \( String(describing: board?.indicesToAdd))")
            if let index = board?.indicesToAdd.first {
                print(currentBoardCards[index[0]][index[1]])
            }
            print("To Remove \(String(describing: board?.indicesToRemove))")
            if let index = board?.indicesToRemove.first {
                print(currentBoardCards[index[0]][index[1]])
            }
            var maxScore = 0
            var maxScoreBoardCard = Card()
            var selectingCard : Card?
            for cardOnHand in opponentCards {
                if cardOnHand.isItATwoEyedJack {
                    if let indexes = board?.indicesToAdd.first(where: {
                        currentBoardCards[$0[0]][$0[1]].coin == nil && !opponentCards.contains(currentBoardCards[$0[0]][$0[1]]) && board?.getScoreForTheGivenIndexAndCoin(index: ($0[0],$0[1]), coin: .green) == 4
                    }) {
                        selectingCard = cardOnHand
                        withAnimation {
                            inSelectionCard = selectingCard
                        }
                        await delayAutomaticTurn()
                        let boardCard = currentBoardCards[indexes[0]][indexes[1]]
                        if selectACardByOpponent(boardCard, selectingCard : selectingCard) != nil {
                            withAnimation {
                                inSelectionCard = nil
                            }
                            myTurn = true
                            return
                        }
                        else { print("Two Eye") }
                        
                    }
                }
                if cardOnHand.isItAOneEyedJack {
                    if let indexes = board?.indicesToRemove.first(where: {
                        currentBoardCards[$0[0]][$0[1]].coin == .blue && !currentBoardCards[$0[0]][$0[1]].belongsToASequence
                    }) {
                        selectingCard = cardOnHand
                        withAnimation {
                            inSelectionCard = selectingCard
                        }
                        await delayAutomaticTurn()
                        let boardCard = currentBoardCards[indexes[0]][indexes[1]]
                        if !boardCard.belongsToASequence  && selectACardByOpponent(boardCard, selectingCard : selectingCard) != nil {
                            withAnimation {
                                inSelectionCard = nil
                            }
                            myTurn = true
                            return
                        }
                        else { print("One Eye") }
                    }
                }
                else {
                    for boardCard in currentBoardCards.joined().filter({ cardOnHand.hasASameFaceAs($0) && $0.coin == .none }) {
                        if let boardCardIndex = currentBoardCards.indicesOf(x: boardCard), let score = board?.getScoreForTheGivenIndexAndCoin(index: boardCardIndex, coin: .green) {
                            if score > maxScore {
                                maxScore = score; maxScoreBoardCard = boardCard ; selectingCard = cardOnHand
                            }
                        }
                    }
                }
            }
            print("Before eye \(maxScoreBoardCard) \(String(describing: selectingCard)) \(opponentCards) \(String(describing: opponent?.data?.cardsOnHand))")
            withAnimation {
                inSelectionCard = selectingCard
            }
            await delayAutomaticTurn()
            if selectACardByOpponent(maxScoreBoardCard, selectingCard: selectingCard ) != nil {
                withAnimation {
                    inSelectionCard = nil
                }
                myTurn = true
                return
            } else { print("No eye \(maxScoreBoardCard) \(String(describing: selectingCard)) \(opponentCards)") }
        }
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
