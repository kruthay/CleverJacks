//
//  CleverJacksGame+MatchData.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import GameKit
import SwiftUI

// MARK: Game Data Objects

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
    var data : PlayerGameData?
    var isABot = false
    struct PlayerGameData : Codable {
        var cardsOnHand : [Card] = []
        let coin : Coin?
        var noOfSequences = 0
        let currentMatchID : String
        var result : Result = .noResult
        
    }
}

enum Result : Codable {
    case won
    case lost
    case noResult
}


// Codable game data for sending to players.
struct GameData: Codable, CustomStringConvertible {
    var board: Board?
    var cardCurrentlyPlayed : Card?
    var cardRecentlyChanged : Card?
    var allPlayersData : [String: Participant.PlayerGameData]
    var lastPlayedBy: String
    var description: String {
        return "PlayerData : \(allPlayersData) Board : \(String(describing: board))"
    }
    // board ( may be cardstack inside the board )
}

extension CleverJacksGame {
    
    // MARK: Codable Game Data
    
    /// Creates a data representation of the game count and items for each player.
    ///
    /// - Returns: A representation of game data that contains only the game scores.
    func encodeGameData() -> Data? {
        // Create a dictionary of data for each player.
        var allPlayersData = [String: Participant.PlayerGameData]()
        // Add the local player's items.
        var lastPlayedBy = ""
        if let localPlayerId = localParticipant?.player.displayName {
            if let playerGameData = localParticipant?.data {
                allPlayersData[localPlayerId] = playerGameData
            }
        }
        
        // Add the opponent's items.
        
        // Saving for persistance purposes, some values are not decoded
        if let opponentPlayerId = opponent?.player.displayName {
            if opponentPlayerId == "" {
                if let playerGameData = opponent?.data {
                    allPlayersData["Computer"] = playerGameData
                }
            }
            else if let playerGameData = opponent?.data {
                allPlayersData[opponentPlayerId] = playerGameData
            }
        }
        else if opponent?.isABot == true {
            if let playerGameData = opponent?.data {
                allPlayersData["Computer"] = playerGameData
            }
        }
        
        if let opponent2PlayerId = opponent2?.player.displayName {
            
            if let playerGameData = opponent2?.data {
                allPlayersData[opponent2PlayerId] = playerGameData
            }
        }
        
        if let playersName = whichPlayersTurn?.displayName {
            lastPlayedBy = playersName
        }
        
        
        let gameData = GameData(board: board , cardCurrentlyPlayed: cardCurrentlyPlayed, cardRecentlyChanged: cardRecentlyChanged, allPlayersData: allPlayersData, lastPlayedBy: lastPlayedBy)
        
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
        
        if matchData.isEmpty {
            return
        }
        
        do {
            let gameData = try PropertyListDecoder().decode(GameData.self, from: matchData)
            AudioServicesPlaySystemSound(1106)
            // Update Response Cards
            
            cardCurrentlyPlayed = gameData.cardCurrentlyPlayed
            cardRecentlyChanged = gameData.cardRecentlyChanged
                        
            if let cardRecentlyChanged,
                let index = gameData.board?.boardCards.indicesOf(x: cardRecentlyChanged),
                let cardStack = gameData.board?.cardStack,
               let indicesToAdd = gameData.board?.indicesToAdd,
               let indicesToRemove = gameData.board?.indicesToRemove{
                board?.indicesToAdd = indicesToAdd
                board?.indicesToRemove = indicesToRemove
                board?.cardStack = cardStack
                board?.boardCards[index.0][index.1] = cardRecentlyChanged
            }

            
            board = gameData.board
            lastPlayedBy = gameData.lastPlayedBy
            
            
            
            
            if let localPlayerId = localParticipant?.player.displayName {
                
                if let playerGameData = gameData.allPlayersData[localPlayerId] {
                    localParticipant?.data = playerGameData
                }
            }
            
            
            // Saving for persistance purposes, some values are not decoded
            if let opponentPlayerId = opponent?.player.displayName {
                if opponentPlayerId == "" {
                    if let playerGameData = gameData.allPlayersData["Computer"] {
                        opponent?.data = playerGameData
                    }
                }
                else if let playerGameData = gameData.allPlayersData[opponentPlayerId] {
                    opponent?.data = playerGameData
                }
            }
            else if opponent?.isABot == true {
                if let playerGameData = gameData.allPlayersData["Computer"] {
                    opponent?.data = playerGameData
                }
            }
            if let opponent2PlayerID = opponent2?.player.displayName {
                if let playerGameData = gameData.allPlayersData[opponent2PlayerID] {
                    opponent2?.data = playerGameData
                }
            }
            
            
            // Set the opponent's items.
            
            
        } catch {
            matchMessage = "Incompatible App Versions, Reset the Game "
            print("Issues")
            return
        }
    }
}
