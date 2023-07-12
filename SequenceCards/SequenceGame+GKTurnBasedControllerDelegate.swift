//
//  CleverJacksGame+GKTurnBasedControllerDelegate.swift
//  CleverJacks
//
//  Created by Kruthay Kumar Reddy Donapati on 7/3/23.
//

import Foundation

import GameKit
import SwiftUI

extension CleverJacksGame: GKTurnBasedMatchmakerViewControllerDelegate {
    
    /// Dismisses the view controller when either player cancels matchmaking.
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
        
        // Remove the game view.
        resetGame()
    }
    
    /// Handles an error during the matchmaking process and dismisses the view controller.
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription).")
        viewController.dismiss(animated: true)
        
        // Remove the game view.
        resetGame()
    }
    
    
}

