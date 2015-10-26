//
//  GameViewControllerButton.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 10/19/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import Foundation
import SpriteKit


// this is a class for a button that can be used with SKScenes
class GameViewControllerButton: SKSpriteNode {
    var defaultButton: SKSpriteNode
    var action: () -> Void
    
    init(defaultButtonImage: String, buttonAction: () -> Void) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        action = buttonAction
        
        let cardReloadTexture = SKTexture(imageNamed: "reload_card")
        super.init(texture: cardReloadTexture, color: UIColor.blackColor(), size: cardReloadTexture.size())
        
        userInteractionEnabled = true
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        defaultButton.hidden = true
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location: CGPoint = touch.locationInNode(self)
            
            if defaultButton.containsPoint(location) {
                defaultButton.hidden = true
            } else {
                defaultButton.hidden = false
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location: CGPoint = touch.locationInNode(self)
            
            if defaultButton.containsPoint(location) {
                action()
            }
            
            defaultButton.hidden = false
        }
        
    }
}