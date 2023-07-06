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
struct Message: Identifiable {
    var id = UUID()
    var content: String
    var playerName: String
    var isLocalPlayer: Bool = false
}

// A participant object with their items.
struct Participant: Identifiable {
    var id = UUID()
    var player: GKPlayer
    var avatar = Image(systemName: "person")
    var items = 50
    var cardsOnHand : [Card] = []
    var coin : Coin? = nil
    var noOfSequences = 0
}

// Codable game data for sending to players.
struct GameData: Codable {
    var count: Int
    var items: [String: Int]
    var board: Board?
    var cardCurrentlyPlayed : Card?
    var coins: [String: Coin]
    var cardsOnHands : [String : [Card]]
    var noOfSequences: [String: Int]
    // board ( may be cardstack inside the board )
}

extension SequenceGame {
    
    // MARK: Codable Game Data
    
    /// Creates a data representation of the game count and items for each player.
    ///
    /// - Returns: A representation of game data that contains only the game scores.
    func encodeGameData() -> Data? {
        // Create a dictionary of items for each player.
        var items = [String: Int]()
        var coins = [String: Coin]()
        var cardsOnHands = [String : [Card]]()
        var noOfSequences = [String : Int]()
        // Add the local player's items.
        if let localPlayerName = localParticipant?.player.displayName {
            items[localPlayerName] = localParticipant?.items
            coins[localPlayerName] = localParticipant?.coin
            cardsOnHands[localPlayerName] = localParticipant?.cardsOnHand
            noOfSequences[localPlayerName] = localParticipant?.noOfSequences
        }
        
        // Add the opponent's items.
        if let opponentPlayerName = opponent?.player.displayName {
            items[opponentPlayerName] = opponent?.items
            coins[opponentPlayerName] = opponent?.coin
            cardsOnHands[opponentPlayerName] = opponent?.cardsOnHand
            noOfSequences[opponentPlayerName] = opponent?.noOfSequences
        }
        
        
        
        let gameData = GameData(count: count, items: items, board: board , cardCurrentlyPlayed: cardCurrentlyPlayed, coins: coins, cardsOnHands: cardsOnHands, noOfSequences: noOfSequences)
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
    
    /// Decodes a data representation of game data and updates the scores.
    ///
    /// - Parameter matchData: A data representation of the game data.
    func decodeGameData(matchData: Data) {
        let gameData = try? PropertyListDecoder().decode(GameData.self, from: matchData)
        guard let gameData = gameData else { return }

        // Set the match count.
        count = gameData.count
        
        
        cardCurrentlyPlayed = gameData.cardCurrentlyPlayed
        // update the current board,
        board = gameData.board
        
        

        
        //  we don't need items for now.

        // Set the local player's items.
        if let localPlayerName = localParticipant?.player.displayName {
            if let items = gameData.items[localPlayerName] {
                localParticipant?.items = items
            }
            if let coin = gameData.coins[localPlayerName] {
                localParticipant?.coin = coin
            }
            if let cardsOnHand = gameData.cardsOnHands[localPlayerName]{
                localParticipant?.cardsOnHand = cardsOnHand
            }
            if let noOfSequences = gameData.noOfSequences[localPlayerName]{
                localParticipant?.noOfSequences = noOfSequences
            }
        }

        // Set the opponent's items.
        if let opponentPlayerName = opponent?.player.displayName {
            if let items = gameData.items[opponentPlayerName] {
                opponent?.items = items
            }
            if let coin = gameData.coins[opponentPlayerName] {
                opponent?.coin = coin
            }
            if let cardsOnHand = gameData.cardsOnHands[opponentPlayerName]{
                opponent?.cardsOnHand = cardsOnHand
            }
            if let noOfSequences = gameData.noOfSequences[opponentPlayerName]{
                opponent?.noOfSequences = noOfSequences
            }
        }
    }
}
