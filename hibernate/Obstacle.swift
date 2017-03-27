//
//  Obstacle.swift
//  Spacebear
//
//  Created by Justin Hershey on 3/15/17.
//  Copyright © 2017 Fenapnu. All rights reserved.
//

import SpriteKit


class Obstacle {
    
    let frame: CGRect
    let playerScalingFactor: CGFloat
    let playerWidth: CGFloat
    
    
    init(frame:CGRect){
        
        
        self.frame = frame
        self.playerScalingFactor = 10.0
        self.playerWidth = self.frame.width / playerScalingFactor
        
    }
    
    
    /****************************************************************************
     *
     * _______________________ OBSTACAL CHOOSING METHOD _________________________
     *
     *
     *****************************************************************************/
    
    func addObstacle() -> SKSpriteNode{
        
        let temp = self.random(min:0, max:6)
        let random = Int(temp)
    
        var obstacleNode = SKSpriteNode()


        switch random {
            
            case 0:
                
                let scalingFactor: CGFloat = 3.0
                
                obstacleNode = addWormhole(origin: randomLocation(min:2, max: playerScalingFactor, scalor: scalingFactor), scalingFactor: scalingFactor)
            
            case 1 :
            
                
                let scalingFactor: CGFloat = CGFloat(randomScalor(min: 3, max: playerScalingFactor/2 ))
                
                obstacleNode = addBlackhole(origin: randomLocation(min:0, max: playerScalingFactor, scalor: scalingFactor), scalingFactor: scalingFactor)
            case 2:
            
                obstacleNode = addEngine()
            
            case 3:
            
            
                let scalingFactor: CGFloat = CGFloat(randomScalor(min: 3, max: playerScalingFactor/2 ))
            
                obstacleNode = addBlackhole(origin: randomLocation(min:0, max: playerScalingFactor, scalor: scalingFactor), scalingFactor: scalingFactor)
            
            default:
                
                print("Default Obstacle Case - Star")
                let scalingFactor: CGFloat = CGFloat(randomScalor(min: 2, max: playerScalingFactor/3))
                
                obstacleNode = addStar(origin: randomLocation(min:0, max: playerScalingFactor/2, scalor: scalingFactor), scalingFactor: scalingFactor)
            
        }
        
        obstacleNode.physicsBody?.isDynamic = true
        obstacleNode.physicsBody?.usesPreciseCollisionDetection = true
        obstacleNode.physicsBody?.affectedByGravity = false
        
        //collision Masks
        obstacleNode.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        obstacleNode.physicsBody?.contactTestBitMask = PhysicsCategory.None
        obstacleNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        obstacleNode.physicsBody?.velocity = CGVector(dx: 0, dy:-600)
        
        return obstacleNode
        
    }
    
    
    
    /*****************************************************************************
     *
     * __________________________ RANDOM FLOAT METHODS __________________________
     *
     *****************************************************************************/
    
    
    //returns a random CGFloat
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    //returns random CGFloat within range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    /*****************************************************************************
     *
     * _________________________ RANDOM LOCATION METHOD __________________________
     *
     *****************************************************************************/
    
    
    func randomLocation(min: CGFloat, max: CGFloat, scalor: CGFloat) -> CGPoint{
        
        let diameter = Int(scalor)
        
        // we add on 1/4 of the player scaling factor so the origin can be off to the left or right
        let randomChuteLocation = Int(random(min: 0, max: playerScalingFactor))
        
        var location: CGFloat = 0.0
        
        
        if (diameter % 2 > 0){
            
            //odd number of chutes
            
            location = (CGFloat((randomChuteLocation - 1)) * playerWidth + playerWidth / 2)
            
        }else{
            
            location = CGFloat(randomChuteLocation) * playerWidth
            
        }
        
        let origin = CGPoint(x: location, y: frame.size.height + scalor * playerWidth)
        
        
        return origin
        
    }
    
    /****************************************************************************
     *
     * __________________________ RANDOM SIZE METHOD ___________________________
     *
     *****************************************************************************/
    
    
    func randomScalor(min: CGFloat, max: CGFloat) -> Int {
        
        let randomScalor = Int(random(min: min, max: max))
        return randomScalor
        
    }
    
    
    
    /****************************************************************************
     *
     * ________________________ OBSTACLE FLAVOR METHODS __________________________
     *
     *****************************************************************************/
    
    
    
    //returns an SKShapeNode wormhole obstacle -- blue circle for now
    func addWormhole(origin: CGPoint, scalingFactor: CGFloat) -> SKSpriteNode{
        
        let wormholeNode = SKSpriteNode.init(imageNamed: "Wormhole")
        
        let radius = (playerWidth / 2) * 3
        
        wormholeNode.name = "wormholeNode"
        
        //Position and Size
        wormholeNode.position = origin
        wormholeNode.zPosition = -4
        
        wormholeNode.size = CGSize(width: radius * 2, height: radius * 2)
        
        wormholeNode.physicsBody = SKPhysicsBody(circleOfRadius: radius - radius / 10)
        
        return wormholeNode
        
    }
    
    
    //returns an SKShapeNode wormhole obstacle -- yello circle for now
    func addStar(origin: CGPoint, scalingFactor: CGFloat) -> SKSpriteNode{
        
        let starNode = SKSpriteNode.init(imageNamed: "star")
        
        let radius = scalingFactor/2 * playerWidth
        
        starNode.name = "starNode"
        
        //Position and Size
        starNode.zPosition = -4
        starNode.position = origin
        starNode.size = CGSize(width: radius * 2, height: radius * 2)
        
        starNode.physicsBody = SKPhysicsBody(circleOfRadius: radius - 4)

        return starNode
        
    }
    
    
    //returns an SKShapeNode wormhole obstacle -- black circle for now
    func addBlackhole(origin: CGPoint, scalingFactor: CGFloat) -> SKSpriteNode{
        
        let blackholeNode = SKSpriteNode.init(imageNamed: "Blackhole")
        
        let radius = scalingFactor/2 * playerWidth
        
        blackholeNode.name = "blackholeNode"
        
        //position and size
        blackholeNode.position = origin
        blackholeNode.size = CGSize(width: radius * 2, height: radius * 2)
        blackholeNode.zPosition = -4
        
        //Physics Body Setup
        blackholeNode.physicsBody = SKPhysicsBody(circleOfRadius: radius - radius / 4)
        

        return blackholeNode
        
    }
    
    func addEngine() -> SKSpriteNode{
        
        print("Dropping Engine")
        let engineNode = SKSpriteNode.init(imageNamed: "Engine")
        
        let origin = randomLocation(min: 0, max: playerScalingFactor, scalor: 2)
        
        let radius = 3*playerWidth/4

        engineNode.name = "engineNode"
        
        //position and size
        engineNode.position = origin
        engineNode.size = CGSize(width: radius * 2, height: radius * 2)
        engineNode.zPosition = -4
        
        engineNode.physicsBody = SKPhysicsBody(circleOfRadius: radius - 2)
        
        return engineNode
    }
    
    
}
