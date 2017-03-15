//
//  GameOverScene.swift
//  hibernate
//
//  Created by Justin Hershey on 3/15/17.
//  Copyright © 2017 Fenapnu. All rights reserved.
//

import SpriteKit


class GameOverScene: SKScene{
    
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.8)
        
        
    }
    
    
    
    
    /**********************************
     *  NAVIGATION
     ***********************************/
    //will goto the game scene -- used
    func goToGameScene(){
        let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 2.0) // create type of transition (you can check in documentation for more transtions)
        gameScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(gameScene, transition: transition)
    }
    
    
    
    
    
}
