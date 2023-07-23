//
//  CleverJacksGame+GKTurnBasedEventListener.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

@preconcurrency import GameKit
import SwiftUI

extension CleverJacksGame : GKTurnBasedEventListener{
    
    /// Creates a match and presents a matchmaker view controller.
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
        startMatch(playersToInvite)
    }
    
    
    /// Handles multiple turn-based events during a match.
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
        // Handles these turn-based events when:
        // 1. The local player accepts an invitation from another participant.
        // 2. GameKit passes the turn to the local player.
        // 3. The local player opens an existing or completed match.
        // 4. Another player forfeits the match.
        switch match.status {
        case .open:
            Task {
                do {
                    // If the match is open, first check whether game play should continue.
                    // Remove participants who quit or otherwise aren't in the match.
                    let nextParticipants = match.participants.filter {
                        $0.status != .done
                    }
                    let localPlayer = match.participants.first {
                        self.localParticipant?.player.displayName == $0.player?.displayName
                    }
                    if localPlayer?.matchOutcome == .lost {
                        youLost = true
                        isGameOver = true
                    }
                    
                    // End the match if active participants drop below the minimum.
                    if nextParticipants.count < decode(matchData: match.matchData!)?.board?.numberOfPlayers ?? 0 {
                        // Set the match outcomes for the active participants.
                        
                        for participant in nextParticipants {
                            if participant.matchOutcome == .none {
                                participant.matchOutcome = .won
                            }
                        }
                        // End the match in turn.
                        try await match.endMatchInTurn(withMatch: match.matchData!)
                        // Notify the local player when the match ends.
                        youWon = true
                        isGameOver = true
                    }
                    else if (currentMatchID == nil) || (currentMatchID == match.matchID) {
                        // If the local player isn't playing another match or is playing this match,
                        // display and update the game view.
                        // Display the game view for this match.
                        playingGame = true
                        if let thisPlayersTurn = match.currentParticipant?.player {
                            self.whichPlayersTurn = thisPlayersTurn
                        }
                        
                        // Remove the local player from the participants to find the opponent.
                        let participants = match.participants.filter {
                            self.localParticipant?.player.displayName != $0.player?.displayName
                        }
                        // If the player starts the match, the opponent hasn't accepted the invitation and has no player object.
                        //  When the Local player is the invitee, participants would be empty and it's time to initialise the local player's coin.
                        if let gameData = decode(matchData: match.matchData!) {
                            /// Use this information and update respective code, if it's not decodable, that means it's the first players turn, else it's not. When it's the first players first turn, update
                            ///   Based on the number of Players, let's say 6 and it's a twoVtwo game, so 3 teams, and hence 3 colors, or if it's threeVthree game, two teams and hence 2 colors, we have to participants and decide how we are going to connect them..
                            ///   It could be completely random, even if we select 3 players, the other 3 players might get automatched.. And as it's turn based, the next participant will always be.. the next person in line..
                            ///   This means they can't automatch with team selection, they always have to select team members. Team members must be alternative or we can add flag them some how to belong to a specific team.
                            
                            for participant in participants {
                                // If participant is nil, then it's first time
                                
                                if (participant.status != .matching) {
                                    if let player = participant.player {
                                        if opponent == nil && opponent2?.player != player {
                                            // Load the opponent's avatar and create the opponent object.
                                            let image = try await player.loadPhoto(for: GKPlayer.PhotoSize.small)
                                            opponent = Participant(player: player,
                                                                   avatar: Image(uiImage: image))
                                            
                                        }
                                        else if opponent2 == nil && gameData.board?.numberOfPlayers ?? 0 > 2 && opponent?.player != player {
                                            let image = try await player.loadPhoto(for: GKPlayer.PhotoSize.small)
                                            opponent2 =  Participant(player: player,
                                                                     avatar: Image(uiImage: image))
                                        }
                                    }
                                }
                                else {
                                    print("Participant is still in Matching")
                                }
                            }
                        }
                        
                        if let player1 = opponent?.player, let player2 = opponent2?.player {
                            if player1 == player2 {
                                print("Error")
                            }
                        }
                        // Restore the current game data from the match object.
                        // oppoents are created before this step so that decoded information is added to their profile.
                        if let currentCardsCount = board?.cardStack.count, let cardCountInTheDecodedGameData = decode(matchData: match.matchData!)?.board?.cardStack.count {
                            if currentCardsCount >= cardCountInTheDecodedGameData {
                                decodeGameData(matchData: match.matchData!)
                            }
                            else {
                                print("InPlayer \(currentCardsCount), \(cardCountInTheDecodedGameData)")
                            }
                        }
                        // When Local Player is invited.
                        if match.currentParticipant?.player == localParticipant?.player {
                            if localParticipant?.data == nil {
                                
                                var assignCoin : Coin?
                                var assignDealtCards : [Card] = []
                                if let coin =  board?.uniqueCoin()  {
                                    assignCoin = coin
                                }
                                else {
                                    print("Coins cannot be nil")
                                    if let gameData = decode(matchData: match.matchData!) {
                                        print(gameData)
                                    }
                                    else {
                                        print("GAME DATA IS NIL MAtch ID: \(String(describing: currentMatchID))")
                                    }
                                }
                                
                                if let cards = board?.dealCards(noOfCardsToDeal: self.noOfCardsToDeal) {
                                    assignDealtCards =  cards
                                }
                                else {
                                    print("Error")
                                }
                                
                                let data = Participant.PlayerGameData(cardsOnHand : assignDealtCards, coin: assignCoin, currentMatchID: match.matchID)
                                localParticipant?.data = data
                            }
                            
                            // Encode the data here
                        }
                        currentMatchID = match.matchID
                        // Display the match message.
                        matchMessage = match.message
                        
                        // Retain the match ID so action methods can load the current match object later.
                        if GKLocalPlayer.local == match.currentParticipant?.player {
                            if let currentPlayersName = match.currentParticipant?.player?.displayName {
                                if currentPlayersName == lastPlayedBy && lastPlayedBy != "" {
                                    print("Current \(currentPlayersName), Previous \(lastPlayedBy)")
                                    match.message = "Network issue"
                                }
                            }
                        }
                        // Update the interface depending on whether it's the local player's turn.
                        myTurn = GKLocalPlayer.local == match.currentParticipant?.player ? true : false
                    }
                } catch {
                    // Handle the error.
                    print("Error: \(error.localizedDescription).")
                }
            }
            
        case .ended:
            Task {
                do {
                    playingGame = true
                    isGameOver = true
                    if let localPlayer = match.participants.first(where: { $0.player?.displayName == localParticipant?.player.displayName }) {
                        youWon = localPlayer.matchOutcome == .won ? true : false
                        youLost = localPlayer.matchOutcome == .lost ? true : false
                    }
                    
                    if youWon {
                        matchMessage = "You Won"
                        
                    }
                    if youLost {
                        matchMessage = "You Lost"
                    }
                    let participants = match.participants.filter {
                        self.localParticipant?.player.displayName != $0.player?.displayName
                    }
                    if let gameData = decode(matchData: match.matchData!) {
                        for participant in participants {
                            
                            if (participant.status != .matching) {
                                if let player = participant.player {
                                    if opponent == nil && opponent2?.player != player {
                                        //                                        // Load the opponent's avatar and create the opponent object. Error When Loading
                                        //                                        let image = try await player.loadPhoto(for: GKPlayer.PhotoSize.small)
                                        opponent = Participant(player: player,
                                                               avatar: Image(systemName: "person.circle"))
                                    }
                                    else if opponent2 == nil && gameData.board?.numberOfPlayers ?? 0 > 2 && opponent?.player != player {
                                        //                                        let image = try await player.loadPhoto(for: GKPlayer.PhotoSize.small)
                                        opponent2 =  Participant(player: player,
                                                                 avatar: Image(systemName: "person.circle"))
                                    }
                                }
                            }
                        }
                    }
                    decodeGameData(matchData: match.matchData!)
                    currentMatchID = match.matchID
                }
            }
            
        case .matching:
            
            Task {
                do {
                    playingGame = true
                    let participants = match.participants.filter {
                        self.localParticipant?.player.displayName != $0.player?.displayName
                    }
                    if let gameData = decode(matchData: match.matchData!) {
                        
                        for participant in participants {
                            
                            if (participant.status != .matching) {
                                if let player = participant.player {
                                    if opponent == nil && opponent2?.player != player {
                                        //                                        // Load the opponent's avatar and create the opponent object.
                                        //                                        let image = try await player.loadPhoto(for: GKPlayer.PhotoSize.small)
                                        opponent = Participant(player: player,
                                                               avatar: Image(systemName: "person.circle"))
                                    }
                                    else if opponent2 == nil && gameData.board?.numberOfPlayers ?? 0 > 2 && opponent?.player != player {
                                        //                                        let image = try await player.loadPhoto(for: GKPlayer.PhotoSize.small)
                                        opponent2 =  Participant(player: player,
                                                                 avatar: Image(systemName: "person.circle"))
                                    }
                                }
                            }
                        }
                        
                    }
                    decodeGameData(matchData: match.matchData!)
                    currentMatchID = match.matchID
                    matchMessage = match.message
                    print("Match ended.")
                }
            }
            
        default:
            print("Match Status is unknown")
            print("Status unknown.")
        }
    }
    
    /// Handles when a player forfeits a match when it's their turn using the view controller interface.
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        // Remove the current participant. If the count drops below the minimum, the next participant ends the match.
        let nextParticipants = match.participants.filter {
            $0 != match.currentParticipant
        }
        
        // Quit while it's the local player's turn.
        match.participantQuitInTurn(with: GKTurnBasedMatch.Outcome.quit, nextParticipants: nextParticipants,
                                    turnTimeout: GKTurnTimeoutDefault, match: match.matchData!)
    }
    
    /// Handles when a participant ends the match using the view controller interface.
    func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        // Notify the local participant when the match ends.
        playingGame = true
        //        if let localPlayer = match.participants.first(where: { $0.player?.displayName == localParticipant?.player.displayName }) {
        //        youWon = localPlayer.matchOutcome == .won ? true : false
        //        youLost = localPlayer.matchOutcome == .lost ? true : false
        //    }
        print("In the player matchEnded")
        //        GKNotificationBanner.show(withTitle: "Match Ended Title",
        //                                  message: "This is a GKNotificationBanner message.", completionHandler: nil)
        //
        //        // Check whether the local player is playing the match that ends before returning to the content view.
        //        if currentMatchID == match.matchID {
        //            resetGame()
        //        }
    }
    
    // MARK: GKTurnBasedEventListener Exchange Methods
    
    /// Handles when the local player receives an exchange request from another participant.
    func player(_ player: GKPlayer, receivedExchangeRequest exchange: GKTurnBasedExchange,
                for match: GKTurnBasedMatch) {
        if exchange.data != nil {
            if exchange.message != "This is my exchange item request." {
                // Unpack the exchange data and display the message in the chat view.
                let content = String(decoding: exchange.data!, as: UTF8.self)
                let message = Message(content: content, playerName: exchange.sender.player?.displayName ?? "unknown", isLocalPlayer: false)
                messages.append(message)
                unViewedMessages.append(message)
            }
            
            // Reply to the exchange request.
            switch exchange.status {
            case .active:
                Task {
                    do {
                        // Alternatively, you can parse the message to present the request before accepting.
                        try await exchange.reply(withLocalizableMessageKey: "I accept the exchange request.", arguments: [], data: Data())
                    } catch {
                        // Handle the error.
                        print("Error: \(error.localizedDescription).")
                    }
                }
            case .complete:
                print("Exchange complete.")
            case .resolved:
                print("Exchange resolved.")
            case .canceled:
                print("Exchange canceled.")
            default:
                print("Exchange default.")
            }
        }
    }
    
    /// Handles when the sender cancels an exchange request.
    func player(_ player: GKPlayer, receivedExchangeCancellation exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
    }
    
    /// Handles when all players either respond or time out responding to this request.
    func player(_ player: GKPlayer, receivedExchangeReplies replies: [GKTurnBasedExchangeReply],
                forCompletedExchange exchange: GKTurnBasedExchange, for match: GKTurnBasedMatch) {
        // GameKit sends this message to both the current participant and the sender of the exchange request.
        saveExchanges(for: match)
    }
    
    /// Exchanges the items and removes completed exchanges from the match object.
    /// - Tag:saveExchanges
    func saveExchanges(for match: GKTurnBasedMatch) {
        // Check whether the local player is the current participant who can save exchanges.
        guard myTurn else { return }
        
        // Save all the completed exchanges.
        if let completedExchanges = match.completedExchanges {
            
            for exchange in completedExchanges where exchange.message == "This is my exchange item request."{
                // For all exchange item requests, transfer an item from the recipient to the sender.
                //                if exchange.sender.player == localParticipant?.player {
                //                    // Transfer an item from the opponent to the local player.
                //                    opponent?.items -= 1
                //                    localParticipant?.items += 1
                //                } else {
                //                    // Transfer an item from the local player to the opponent.
                //                    localParticipant?.items -= 1
                //                    opponent?.items += 1
                //                }
                // For text message exchange requests, do nothing.
            }
            
            // Resolve the game data to pass to all participants.
            let gameData = (encodeGameData() ?? match.matchData)!
            
            // Save and forward the game data with the latest items.
            Task {
                try await match.saveMergedMatch(gameData, withResolvedExchanges: completedExchanges)
            }
        }
    }
}
