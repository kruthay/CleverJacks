//
//  SequenceGame+MatchData.swift
//  SequenceCards
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import GameKit
import SwiftUI

// MARK: Game Data Objects

// A message that one player sends to another.
//struct Message: Identifiable {
//    var id = UUID()
//    var content: String
//    var playerName: String
//    var isLocalPlayer: Bool = false
//}

// A participant object with their items.
struct Participant: Identifiable {
    var id = UUID()
    var player: GKPlayer
    var avatar = Image(systemName: "person")
    var cardsOnHand : [Card] = []
    var coin : Coin? = nil
    var noOfSequences = 0
    var turns = 0
}

// Codable game data for sending to players.
struct GameData: Codable, CustomStringConvertible {
    var board: Board?
    var cardCurrentlyPlayed : Card?
    var coins: [String: Coin]
    var cardsOnHands : [String : [Card]]
    var noOfSequences: [String: Int]
    var totalTurns : [String: Int]
    var description: String {
        return "Coins : \(coins) Board : \(String(describing: board)) totalTurns \(totalTurns)"
    }
    // board ( may be cardstack inside the board )
}

extension SequenceGame {
    
    // MARK: Codable Game Data
    
    /// Creates a data representation of the game count and items for each player.
    ///
    /// - Returns: A representation of game data that contains only the game scores.
    func encodeGameData() -> Data? {
        // Create a dictionary of items for each player.
        var coins = [String: Coin]()
        var cardsOnHands = [String : [Card]]()
        var noOfSequences = [String : Int]()
        var totalTurns = [String: Int]()
        // Add the local player's items.
        if let localPlayerName = localParticipant?.player.displayName {
            if let cardsOnHand = localParticipant?.cardsOnHand {
                cardsOnHands[localPlayerName] = cardsOnHand
            }
            if let noOfSequence = localParticipant?.noOfSequences {
                noOfSequences[localPlayerName] = noOfSequence
            }
            if let coin = localParticipant?.coin {
                coins[localPlayerName] = coin
            }
            if let turns = localParticipant?.turns {
                totalTurns[localPlayerName] = turns
            }
        }
        
        // Add the opponent's items.
        
        // Saving for persistance purposes, some values are not decoded
        if let opponentPlayerName = opponent?.player.displayName {
            if let cardsOnHand = opponent?.cardsOnHand {
                cardsOnHands[opponentPlayerName] = cardsOnHand
            }
            if let coin = opponent?.coin {
                coins[opponentPlayerName] = coin
            }
            if let noOfSequence = opponent?.noOfSequences {
                noOfSequences[opponentPlayerName] = noOfSequence
            }
            if let turns = opponent?.turns {
                totalTurns[opponentPlayerName] = turns
            }
        }
        
        if let opponent2PlayerName = opponent2?.player.displayName {
            
            if let cardsOnHand = opponent2?.cardsOnHand {
                cardsOnHands[opponent2PlayerName] = cardsOnHand
            }
            if let coin = opponent2?.coin {
                coins[opponent2PlayerName] = coin
            }
            if let noOfSequence = opponent2?.noOfSequences {
                noOfSequences[opponent2PlayerName] = noOfSequence
            }
            if let turns = opponent2?.turns {
                totalTurns[opponent2PlayerName] = turns
            }
        }
        
        
        let gameData = GameData(board: board , cardCurrentlyPlayed: cardCurrentlyPlayed, coins: coins, cardsOnHands: cardsOnHands, noOfSequences: noOfSequences, totalTurns: totalTurns)
        return encode(gameData: gameData)
    }
    
    /// Creates a data representation from the game data for sending to other players.
    ///
    /// - Returns: A representation of the game data.
    func encode(gameData: GameData) -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(gameData)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }
    
    func decode(matchData: Data) -> GameData? {
        let gameData = try? PropertyListDecoder().decode(GameData.self, from: matchData)
        if let gameData = gameData {
            return gameData
        }
        return nil
    }
    
    /// Decodes a data representation of game data and updates the scores.
    ///
    /// - Parameter matchData: A data representation of the game data.
    func decodeGameData(matchData: Data) {
        let gameData = try? PropertyListDecoder().decode(GameData.self, from: matchData)
        guard let gameData = gameData else { return }
        
        // Set the match count.
        
        cardCurrentlyPlayed = gameData.cardCurrentlyPlayed
        // update the current board,
        board = gameData.board
        

        //  we don't need items for now.
        
        // Set the local player's items.
        if let localPlayerName = localParticipant?.player.displayName {
            
            if let coin = gameData.coins[localPlayerName] {
                localParticipant?.coin = coin
            }
            if let cardsOnHand = gameData.cardsOnHands[localPlayerName]{
                localParticipant?.cardsOnHand = cardsOnHand
            }
            if let noOfSequences = gameData.noOfSequences[localPlayerName]{
                localParticipant?.noOfSequences = noOfSequences
            }
            if let turns = gameData.totalTurns[localPlayerName]{
                localParticipant?.turns = turns
            }
            
        }
        
        // Set the opponent's items.
        if let opponentPlayerName = opponent?.player.displayName {
            
            if let coin = gameData.coins[opponentPlayerName] {
                opponent?.coin = coin
            }
            if let cardsOnHand = gameData.cardsOnHands[opponentPlayerName]{
                opponent?.cardsOnHand = cardsOnHand
            }
            if let noOfSequences = gameData.noOfSequences[opponentPlayerName]{
                opponent?.noOfSequences = noOfSequences
            }
            if let turns = gameData.totalTurns[opponentPlayerName]{
                opponent?.turns = turns
            }
        }
        
        
        if let opponent2PlayerName = opponent2?.player.displayName {
            
            if let coin = gameData.coins[opponent2PlayerName] {
                opponent2?.coin = coin
            }
            if let cardsOnHand = gameData.cardsOnHands[opponent2PlayerName]{
                opponent2?.cardsOnHand = cardsOnHand
            }
            if let noOfSequences = gameData.noOfSequences[opponent2PlayerName]{
                opponent2?.noOfSequences = noOfSequences
            }
            if let turns = gameData.totalTurns[opponent2PlayerName]{
                opponent2?.turns = turns
            }
        }
    }
}
