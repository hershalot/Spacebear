//
//  GameOverScene.swift
//  Spacebear
//
//  Created by Justin Hershey on 3/15/17.
//  Copyright © 2017 Fenapnu. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameOverScene: SKScene {
    
    
    
    var resetNode: SKSpriteNode = SKSpriteNode()
    var scoreNode: SKSpriteNode = SKSpriteNode()
    
    var scoreLbl: SKLabelNode = SKLabelNode.init(text: "Start Over?")
    var resetBtn: SKLabelNode = SKLabelNode.init(text: "")
    var score: Int = 0
    
    
    var highScoreNode: SKSpriteNode = SKSpriteNode()
    var highScoreLbl: SKLabelNode = SKLabelNode.init(text: "")
    var highScore: Int = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        
        let defaults = UserDefaults.standard
        
        self.score = defaults.integer(forKey: "score")
        self.highScore = self.updateHighScore(defaults: defaults, score: self.score)
        
        self.backgroundColor = UIColor.init(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.8)
        
        
        resetNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.size.width/2, height: self.size.height/9))
        
        resetNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY);
        
        
        scoreNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.size.width/3, height: self.size.height/9))
        
        scoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + resetNode.frame.size.height + 10);
        
        
        highScoreNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.size.width/3, height: self.size.height/9))
        
        highScoreNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - resetNode.frame.size.height + 10);
        
        
        scoreLbl.text = "Score: " + String(describing: self.score)
        scoreLbl.fontColor = UIColor.white
        scoreLbl.fontSize = 24.0
        scoreLbl.fontName = "Arial"
        scoreLbl.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
        highScoreLbl.text = "High Score: " + String(describing: self.highScore)
        highScoreLbl.fontColor = UIColor.white
        highScoreLbl.fontSize = 24.0
        highScoreLbl.fontName = "Arial"
        highScoreLbl.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        
        resetBtn.text = "Play Again"
        resetBtn.fontColor = UIColor.red
        resetBtn.fontSize = 50.0
        resetBtn.fontName = "Arial"
        resetBtn.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        

        resetNode.addChild(resetBtn)
        scoreNode.addChild(scoreLbl)
        highScoreNode.addChild(highScoreLbl)
        
        addChild(resetNode)
        addChild(scoreNode)
        addChild(highScoreNode)
    }
    
    
    func updateHighScore(defaults: UserDefaults, score: Int) -> Int{
        var highScore = defaults.integer(forKey: "highScore")
        
        if ( highScore < score){
            
            defaults.set(score, forKey: "highScore")
            
            highScore = score
            
            defaults.synchronize()
            
        }
        
        return highScore
        
        
    }
    
    
    /****************************************************************************
     *  TOUCH DELEGATE METHODS
     *****************************************************************************/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        

        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        

        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
//            let location = touch.location(in: self)
            // Check if the location of the touch is within the button's bounds
//            if resetNode.contains(location) {
                print("tapped!")
                self.goToGameScene()
//            }
//        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //cancelled touches
    }
    
    
    
    
    /**********************************
     *  NAVIGATION
     ***********************************/
    //will goto the game scene -- used
    func goToGameScene(){
        
        self.removeAllActions()
        let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
        
        
        self.view!.presentScene(gameScene, transition: transition)
    }
    
    
    
    
    
}
