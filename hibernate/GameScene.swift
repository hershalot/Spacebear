//
//  GameScene.swift
//  hibernate
//
//  Created by Justin Hershey on 3/12/17.
//  Copyright © 2017 Fenapnu. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


////collision physics struct
struct PhysicsCategory {
    
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Wall      : UInt32 = 0b1       // 1
    static let Wormhole  : UInt32 = 0b10      // 2
    static let Star      : UInt32 = 0b11      // 3
    static let Blackhole : UInt32 = 0b100     // 4
    static let Player    : UInt32 = 0b101     // 5
    

    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //bear sprite
    let player = SKSpriteNode(imageNamed: "Woolybear")
    
    //backgrounds for making the apearance of movement
    let background1 = SKSpriteNode(imageNamed: "NightSky")
    let background2 = SKSpriteNode(imageNamed: "NightSky")

    //user touch location
    var touchPoint: CGPoint = CGPoint()
    
    //if user is touching the bear sprite for initial launch
    var touching: Bool = false
    
    //variable to allow the user to move the bear/player sprite. set to false after initial launch
    var movePlayer: Bool = true
    
    //collision physics frame
    var bodyFrame = CGRect()
    
    //if false background movement is reversed
    var fowardMovement = true
    
    //set to true with initial top collision
    var topHit = false
    
    //set to true on game start
    var moveBackground = false
    
    //vector for
    var vec = CGVector()
    let motionManager = CMMotionManager()
    let scrollSpeed: CGFloat = CGFloat()
    
    //variables for top/bottomm collision walls, changed on top wall collision
    var cruisingHeight = CGFloat()
    var topCollide = CGFloat()
    
    
    //the velocity of the thrown bear sprite, translates to overall game speed faster throw = faster game
    var throwVelocity: CGVector = CGVector()
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        self.addPlayer(atPosition: CGPoint(x: size.width/2, y: size.height * 0.1))
        
        topCollide = self.size.height / 3
        cruisingHeight = self.size.height / 3
        
        bodyFrame = CGRect(x:0, y:0, width: self.size.width, height: self.size.height - topCollide + player.size.height)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: bodyFrame)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        /**********************************
         *  Background Setup
         ***********************************/
        
        background1.size = self.size
        background1.anchorPoint = CGPoint.zero;
        background1.position = CGPoint(x:0, y:0)
        background1.zPosition = -5.0;
        addChild(background1)
        
        background2.size = self.size
        background2.anchorPoint = CGPoint.zero;
        background2.position = CGPoint(x:0, y:background2.size.height)
        background2.zPosition = -5.0;
        addChild(background2)

        
        
        motionManager.accelerometerUpdateInterval = 0.025

    }
    
    
    //Adding Nodes
    func addPlayer(atPosition: CGPoint){
        
        let position: CGPoint = atPosition
        
        player.size = CGSize(width: self.size.width / 10, height: self.size.height / 11)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.position = position
        
        player.zPosition = 1.0;
        addChild(player);
    }
    
    
    //produces a random CGFloat
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    //produces random CGFloat within range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func configureAndAddObstacle() {
        
        //origin point
        let oPoint = CGPoint(x: self.random(min: 0, max: self.size.width), y: self.size.height + self.size.height / 2)
        
        let o: Obstacle = Obstacle(point: oPoint,frame: self.frame)
        
        
        let obstacle = o.addObstacle()
        obstacle.position = oPoint
        
        //add falling down action
        addChild(obstacle)
        
        obstacle.physicsBody = SKPhysicsBody(circleOfRadius: obstacle.frame.size.width/2)
        obstacle.physicsBody?.isDynamic = false
        
        
        switch obstacle.name! as String {
            
        case "starNode":
            
            obstacle.physicsBody?.categoryBitMask = PhysicsCategory.Star
        
        case "wormholeNode":
            
            obstacle.physicsBody?.categoryBitMask = PhysicsCategory.Wormhole
            
        case "blackholeNode":
            
            obstacle.physicsBody?.categoryBitMask = PhysicsCategory.Blackhole
            
        default:
            
            obstacle.physicsBody?.categoryBitMask = PhysicsCategory.None
            
        }
        
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.None
        obstacle.physicsBody?.usesPreciseCollisionDetection = true

        let actualDuration = 1.5
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: obstacle.position.x, y: -obstacle.frame.size.height ), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        obstacle.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    
    /**********************************
     *
     *  SWIPE SELECTOR METHODS
     *
     ***********************************/
    
    func swipedRight(){
        
        print("swiped Right")
        let distance = self.size.width/4
        
        var jumpRight: SKAction = SKAction()
        
        let jumpTime = 0.1
        
        print(player.position.x)
        print(player.size.width)
        print(distance)
        
        if (player.position.x + player.size.width + distance > self.size.width){
            
            jumpRight = SKAction.move(to: CGPoint(x: self.size.width - player.size.width / 2, y: player.position.y), duration: jumpTime)
            
            
        }else{
            
            jumpRight = SKAction.move(to: CGPoint(x: player.position.x + distance, y: player.position.y), duration: jumpTime)
            
        }
        
        player.physicsBody?.velocity = CGVector(dx:0,dy:0)
        player.run(jumpRight)
        
    }
    
    
    func swipedLeft(){
    
        print("swiped Left")
        
        let distance = -self.size.width/3
        
        var jumpLeft: SKAction = SKAction()
        let jumpTime = 0.1
        
        print(player.position.x)
        print(player.size.width)
        print(distance)
        
        if (player.position.x + distance < 0){
            
            jumpLeft = SKAction.move(to: CGPoint(x: player.size.width / 2, y: player.position.y), duration: jumpTime)
            
        }else{
            
            jumpLeft = SKAction.move(to: CGPoint(x: player.position.x + distance, y: player.position.y), duration: jumpTime)
            
        }
        
        player.physicsBody?.velocity = CGVector(dx:0,dy:0)
        player.run(jumpLeft)
        
    }
    
     func swipedUp(){
        
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70));
    }
    
    func swipedDown(){
        
        self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -70));
    }
    
    
    

    
    /*******************************************
    *
    * TOUCH DELEGATE METHODS
    *
    ********************************************/
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first! as UITouch
        
        let location = touch.location(in: self)
        
        if player.frame.contains(location) && movePlayer {
            touchPoint = location
            touching = true
        }

    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        guard let touch = touches.first else {
            return
        }
            
        let location = touch.location(in: self)
        touchPoint = location
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        movePlayer = false
        touching = false
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        //cancelled touches
    }
    
    
    
    
    /**********************************
     *
     *  PHYSICS COLLISION METHOD
     *
     ***********************************/
    
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactPoint = contact.contactPoint
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Wall collision
        if ((firstBody.categoryBitMask & PhysicsCategory.Wall != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if  let player = secondBody.node as? SKSpriteNode {
                let wall = firstBody
                
                playerDidCollideWithFrame(player: player, wall: wall, contactPoint: contactPoint)
            }
        }
        
        
        //Star Collision
        if ((firstBody.categoryBitMask & PhysicsCategory.Star != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if  let player = secondBody.node as? SKSpriteNode, let ball = firstBody.node as? SKShapeNode {
                
                
                playerDidCollideWithObstacle(player: player, ball: ball)
            }
        }
            
        //Wormhole Collision
        else if ((firstBody.categoryBitMask & PhysicsCategory.Wormhole != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if  let player = secondBody.node as? SKSpriteNode, let ball = firstBody.node as? SKShapeNode{
                
                playerDidCollideWithObstacle(player: player, ball: ball)
            }
        }
            
        //BlackHold collision
        else if ((firstBody.categoryBitMask & PhysicsCategory.Blackhole != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if  let player = secondBody.node as? SKSpriteNode, let ball = firstBody.node as? SKShapeNode {
                
                playerDidCollideWithObstacle(player: player, ball: ball)
                
            }
        }
        
    }
    
    /**********************************
     *
     *  PLAYER COLLISION METHODS
     *
     ***********************************/
    

    
    
    func playerDidCollideWithObstacle(player: SKSpriteNode, ball: SKShapeNode) {
        
        
        if(ball.name == "wormholeNode"){
            
            print("Collision with Wormhole")
            
            
        }else if (ball.name == "blackholeNode"){
            
            print("Collision with Black Hole")
            self.gameOver()
            
        }else if(ball.name == "starNode"){
            
            print("Collision with Star")
            self.gameOver()
        }
    }
    
    
    func playerDidCollideWithFrame(player: SKSpriteNode, wall: SKPhysicsBody, contactPoint: CGPoint) {
        
        
        print(contactPoint)
        //left wall hit
        if(contactPoint.x <= 5 && contactPoint.x >= -5 ){

            print("hit left wall")
//            player.physicsBody?.applyImpulse(CGVector.init(dx: (player.physicsBody?.velocity.dx)! * 0.05, dy: (player.physicsBody?.velocity.dy)! * 0.1))
            
            
        }
        
            
        //right wall hit
        else if( contactPoint.x <= self.size.width + 5 && contactPoint.x >= self.size.width - 5){
            
            print("hit right wall")
//            player.physicsBody?.applyImpulse(CGVector.init(dx: (player.physicsBody?.velocity.dx)! * 0.05, dy: (player.physicsBody?.velocity.dy)! * 0.1))
            
        }
      
        /*
         *this following will fail if the sprite hits within +- 5 on the top
         *
         * I should setup a separate Physical catagory for the top wall
         *this works for now
         */
           
            
        //top wall hit
        else if(contactPoint.y <= self.bodyFrame.height + 5 && contactPoint.y >= self.bodyFrame.height - 5 && !topHit){
            
            print("hit top wall")
            topHit = true
            self.moveBackground = true
        
            let realDest = CGPoint(x: player.position.x, y: self.cruisingHeight - self.player.size.height / 2)
                
            let actionMove = SKAction.move(to: realDest, duration: 1.5)
            actionMove.timingMode = .easeInEaseOut
            
                
            player.run((actionMove), completion: {
                NSLog("Done Action")
                
                //velocity to 0, 0 or it will keep falling to bottom
                self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

                /*
                 *
                 * Motion Manager Block below to enable x-axis acceleration on tilt -- mild tilt assist, nothing drastic
                 *
                 */
                
                self.bodyFrame = CGRect(x:0, y: self.cruisingHeight - self.player.size.height, width: self.size.width, height: self.size.height - self.topCollide + self.player.size.height)
                
                print(self.cruisingHeight - self.player.size.height)
                print()
                
                self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.bodyFrame)
                
                self.physicsWorld.gravity = CGVector.init(dx: 0, dy: -9.8)
                
                self.motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data: CMAccelerometerData?, error: Error?) in
                    
                    self?.vec = CGVector(dx:CGFloat((data?.acceleration.x)!), dy:CGFloat((data?.acceleration.y)!))
                
                    self?.player.physicsBody?.applyForce(CGVector(dx: ((self?.vec.dx)! * 30), dy: 0))
                }
                
                self.run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.run(self.configureAndAddObstacle),
                        SKAction.wait(forDuration: 1.0)
                        ])
                ))
                
                let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
                swipeRight.direction = .right
                self.view?.addGestureRecognizer(swipeRight)
                
                
                let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
                swipeLeft.direction = .left
                self.view?.addGestureRecognizer(swipeLeft)
                
                let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedUp))
                swipeUp.direction = .up
                self.view?.addGestureRecognizer(swipeUp)
                
                let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedDown))
                swipeDown.direction = .down
                self.view?.addGestureRecognizer(swipeDown)
            })
            
            
        }
        
            
        //bottom wall hit
        else if(contactPoint.y <= 5 && contactPoint.y >= -5){

            print("hit bottom wall")
//            player.physicsBody?.applyImpulse(CGVector.init(dx: 1, dy: (player.physicsBody?.velocity.dy)! * 0.4 ))
        }
        
    }
    

    
    /**********************************
     *
     *  SKVIEW UPDATE DELEGATE METHOD
     *
     ***********************************/
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        //when touching the bear sprite adjust the velocity of the throw which translates to a faster background scroll
        if touching {
            
            let dt:CGFloat = 1.0/60.0
            let distance = CGVector(dx: touchPoint.x-player.position.x, dy: touchPoint.y-player.position.y)
            let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
            player.physicsBody!.velocity = CGVector.init(dx:velocity.dx * 0.3, dy:velocity.dy * 0.3)

        }
        
        

        if moveBackground && fowardMovement{
            
            background1.position = CGPoint(x: background1.position.x, y: background1.position.y - 9)
            background2.position = CGPoint(x:background2.position.x, y:background2.position.y - 9)
            
            
            if(background1.position.y < -background1.size.height)
            {
                background1.position = CGPoint(x:background2.position.x, y:background1.position.y + 2*background2.size.height )
//                background1.position = CGPoint(x:background2.position.x, y:background1.size.height - 10)
            }
            
            if(background2.position.y < -background2.size.height)
            {
                background2.position = CGPoint(x:background1.position.x, y:background2.position.y + 2*background1.size.height)
//                background2.position = CGPoint(x:background1.position.x, y:background2.size.height - 10)
                
            }
        }
        
        //reverses game for wormholes
        if moveBackground && !fowardMovement{
            
            background1.position = CGPoint(x: background1.position.x, y: background1.position.y + 20)
            background2.position = CGPoint(x:background2.position.x, y:background2.position.y + 20)
            
            
            if(background1.position.y > background1.size.height)
            {
                background1.position = CGPoint(x:background2.position.x, y:background1.position.y - background2.size.height )
                //                background1.position = CGPoint(x:background2.position.x, y:background1.size.height - 10)
            }
            
            if(background2.position.y < -background2.size.height)
            {
                background2.position = CGPoint(x:background1.position.x, y:background2.position.y - background1.size.height)
                //                background2.position = CGPoint(x:background1.position.x, y:background2.size.height - 10)
                
            }
        }
    }
    
    
    
    
    /**********************************
     *
     *  ENDGAME AND NAVIGATION METHODS
     *
     ***********************************/
    
    //will goto the game over scene
    func goToGameOverScene(){
        let gameOverScene:GameOverScene = GameOverScene(size: self.view!.bounds.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 2.0) // create type of transition (you can check in documentation for more transtions)
        gameOverScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(gameOverScene, transition: transition)
    }
    
    //GAME OVER
    
    func gameOver(){
        
        self.moveBackground = false
        self.removeAllActions()
        self.goToGameOverScene()
        
    }
}
