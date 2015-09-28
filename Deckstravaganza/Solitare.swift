//
//  Solitare.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/20/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation

class Solitare: CardGame {
    
    //Properties from protocol of card game
    var deck: Deck
    
    // Properties of solitare
    var wastePile: StackPile        // where the three cards are placed that you can chose from
    var foundations: [StackPile]    // where you have to place A -> King by suit
    var tableus: [StackPile]        // The piles of cards you can add onto
    
    var players = ["Player 1": 0]   // only one player... hence SOLITARE
    
    let gameDelegate = SolitareDelegate()
    
    // initializer
    init() {
        // deals the cards out for the first and only time
        // calls from solitare delagate
        gameDelegate.deal(self)
        
    }
    
    // Methods
    func play() {
        gameDelegate.deal(self)
        gameDelegate.gameDidStart(self)
        
    }
}

class SolitareDelegate: CardGameDelegate {
    var numberOfTurns = 0
    func deal(Game: Solitare) {
        
        // calls a brand new, newly shuffled deck
        Game.deck = Deck.newDeck()
        
        // creates empty stacks for all three piles
        Game.wastePile = StackPile()
        Game.foundations = [StackPile]()
        Game.tableus = [StackPile]()
        
        // places the cards into the tableus 1->7
        for var i = 1; i < 7; i++ {
            for var j = 0; j < i; j++ {
                Game.deck.pop = Game.foundations[i].push
            }
        }
    }
    
    
    // these are used to keep track of the status of the game
    func gameDidStart(Game: CardGame) {
        
    }
    func gameDidEnd(Game: CardGame) {
        
    }
    func isWinner(Game: CardGame) {
        
    }
    
    // used to keep track of the rounds
    func roundDidStart(Game: CardGame) {
        
    }
    func roundDidEnd(Game: CardGame) {
        
    }
    
    // keeps score for the player
    func increaseScore(Game: CardGame) {
        
    }

}