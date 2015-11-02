//
//  GameSceneViewController.swift
//  Deckstravaganza
//
//  Created by LT Carbonell on 9/29/15.
//  Copyright © 2015 University of Florida. All rights reserved.
//

import SpriteKit


class GameSceneViewController: UIViewController {
    var gameScene: SKScene!
    var game: Rummy!
    var gameDelegate: RummyDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let spriteView: SKView = self.view as! SKView
        spriteView.showsDrawCount = true
        spriteView.showsNodeCount = true
        spriteView.showsFPS = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //solitaireScene = SolitaireScene(size: CGSizeMake(768, 1024))
        let gameName = "Solitaire"
//        if gameName == "Solitaire" {
//            self.game = Solitaire()
//            self.gameDelegate = SolitaireDelegate()
//            self.gameScene = SolitaireScene(gameScene: self, size: CGSizeMake(768, 1024))
//        } else if gameName == "Rummy" {
            self.game = Rummy(numberOfPlayers: 2)
            self.gameDelegate = RummyDelegate()
            self.gameScene = RummyScene(gameScene: self, size: CGSizeMake(768, 1024))
//        }
        let spriteView:SKView = self.view as! SKView
        spriteView.presentScene(gameScene)
        
    }

    /*
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
