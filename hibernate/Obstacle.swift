//
//  Obstacle.swift
//  hibernate
//
//  Created by Justin Hershey on 3/15/17.
//  Copyright © 2017 Fenapnu. All rights reserved.
//

import SpriteKit


class Obstacle {
    
    let location: CGPoint
    let frame: CGRect
    
    init(point: CGPoint, frame:CGRect){
        
        self.location = point
        self.frame = frame
    }
    
    
    /**********************************
     *  OBSTACAL CHOOSING METHOD
     ***********************************/
    
    func addObstacle() -> SKShapeNode{
        
        let temp = self.random(min:0, max:3)
        let random = Int(temp)
        
        var obstacleNode = SKShapeNode()
//        print(random)
        
        let rad = self.random(min: self.frame.size.width/8, max: self.frame.width/4)

        switch random {
            
        case 0:
            
            obstacleNode = addWormhole(radius: rad)
            
        case 1:
            
            obstacleNode = addBlackhole(radius: rad)
        case 2:
            
            obstacleNode = addStar(radius: rad)
            
        default:
            
            //do something for nothing
            obstacleNode = addBlackhole(radius: 0)
            print("Add nothing")
        }
        
        return obstacleNode
        
    }
    
    /**********************************
     *  RANDOM FLOAT METHODS
     ***********************************/
    //returns a random CGFloat
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    //returns random CGFloat within range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    /**********************************
     *  OBSTACLE TYPE METHODS
     ***********************************/
    
    
    //returns an SKShapeNode wormhole obstacle -- blue circle for now
    func addWormhole(radius: CGFloat) -> SKShapeNode{
        
        let wormholeNode = SKShapeNode.init(circleOfRadius: radius)
        
        wormholeNode.physicsBody?.affectedByGravity = true
        wormholeNode.physicsBody?.isDynamic  = true
        wormholeNode.zPosition = -4
        wormholeNode.fillColor = UIColor.blue
        wormholeNode.name = "wormholeNode"
        wormholeNode.strokeColor = UIColor.black
        
        return wormholeNode
        
    }
    
    //returns an SKShapeNode wormhole obstacle -- yello circle for now
    func addStar(radius: CGFloat) -> SKShapeNode{
        
        
        let starNode = SKShapeNode.init(circleOfRadius: radius)
        
        starNode.physicsBody?.affectedByGravity = true
        starNode.physicsBody?.isDynamic  = true
        starNode.zPosition = -4
        starNode.fillColor = UIColor.yellow
        starNode.strokeColor = UIColor.orange
        starNode.name = "starNode"
        
        return starNode
    }
    
    
    //returns an SKShapeNode wormhole obstacle -- black circle for now
    func addBlackhole(radius: CGFloat) -> SKShapeNode{
        
        let blackholeNode = SKShapeNode(circleOfRadius: radius)
        blackholeNode.fillColor = UIColor.black
        blackholeNode.strokeColor = UIColor.gray
        blackholeNode.physicsBody?.affectedByGravity = true
        blackholeNode.physicsBody?.isDynamic = true
        blackholeNode.zPosition = -4
        blackholeNode.name = "blackholeNode"
        
        return blackholeNode
    }
    
    
}
