//
//  GameScene.swift
//  Spacebear
//
//  Created by Justin Hershey on 3/12/17.
//  Copyright © 2017 Fenapnu. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


//collision physics struct
struct PhysicsCategory {
    
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Remove    : UInt32 = 0b001
    static let Frame     : UInt32 = 0b010 // 2
    static let Obstacle  : UInt32 = 0b101 // 5
    static let Player    : UInt32 = 0b110 // 6
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    

    //bear sprite
    var player: SKSpriteNode = SKSpriteNode()
    
    //backgrounds for making the apearance of movement
    let background1 = SKSpriteNode(imageNamed: "NightSky")
    let background2 = SKSpriteNode(imageNamed: "NightSky")
    
    var flightSpeed: CGFloat
    
    //check for initial bottom collision
    var startSwipe: Bool
    
    //set to true on game start
    var moveBackground: Bool
    
    //variables for top/bottomm collision walls, changed on top wall collision
    var cruisingHeight: CGFloat
    
    //total score keeper
    var score: Int
    var highScore: Int
    
    //scoring labels and nodes
    var highScoreNode: SKSpriteNode
    var highScoreLbl: SKLabelNode
    
    var scrollCounter: CGFloat
    
    var scoreNode: SKSpriteNode
    var scoreLbl: SKLabelNode
    
    var phaseShift: Bool
    var phaseDuration: CGFloat
    var phaseRecharge: CGFloat
    var slowPulse: Bool
    
    //phase shift timers
    var pulseTimer: Timer
    var phaseTimer: Timer
    var engineTimer: Timer
    
    
    //wormhole variables and contstants
    var wormholeEngine: Bool
    var shrinkPlayer: Bool
    var growPlayer: Bool
    var wormholeTraveling: Bool
    let wormholeScalor: CGFloat
    var wormholeTimer: Timer
    var shrinkWormhole: Bool
    var exitPoint: CGPoint
    let wormholeInc: CGFloat
    var collidedObstacle: SKSpriteNode
    var hasWormholeEngine: SKSpriteNode
    
    var hitBlackhole: Bool
//    var collidedBlackhole: SKSpriteNode
    
    //wormhole radial gravity field
    var field: SKFieldNode
    
    
    //swipe recognizers
    var swipeRight:UISwipeGestureRecognizer
    var swipeLeft:UISwipeGestureRecognizer
    var swipeDown:UISwipeGestureRecognizer
    var swipeUp:UISwipeGestureRecognizer
    
    
    //determines width of player and drop chutes (screenWidth / playerScalingFactor)
    let playerScalingFactor: CGFloat
    
    override init(size: CGSize) {
        
        playerScalingFactor = 10.0
        
        startSwipe = true
        moveBackground = false

        cruisingHeight = CGFloat()
        
        //phase shift variables
        phaseShift = false
        phaseDuration = 10.0
        phaseRecharge = 15.0
        
        //Scoring
        scoreNode = SKSpriteNode()
        scoreLbl = SKLabelNode.init(text: "")
        
        score = 0
        highScore = 0
        
        highScoreNode = SKSpriteNode()
        highScoreLbl = SKLabelNode.init(text: "")
        
        //initialize swipe gestures
        swipeUp = UISwipeGestureRecognizer.init()
        swipeDown = UISwipeGestureRecognizer.init()
        swipeLeft = UISwipeGestureRecognizer.init()
        swipeRight = UISwipeGestureRecognizer.init()
        
        
        //Phase Shift Variables
        pulseTimer  = Timer()
        phaseTimer = Timer()
        slowPulse = true
        
        
        //wormhole variables
        collidedObstacle = SKSpriteNode()
        wormholeEngine = false
        shrinkPlayer = false
        growPlayer = false
        wormholeTraveling = false
        shrinkWormhole = false
        
        wormholeInc = 2.0
        wormholeScalor = 45.0
        wormholeTimer = Timer()
        exitPoint = CGPoint()
        hasWormholeEngine = SKSpriteNode()
        
        hitBlackhole = false
//        collidedBlackhole = SKSpriteNode()
        
        field = SKFieldNode.radialGravityField()
        
        
        //timer for frequency of engine drop
        engineTimer = Timer()
        
        //default speed
        flightSpeed = 9.0
        
        //keeps track of the background scrolling
        scrollCounter = 0.0
    
        
        super.init(size: size)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        print("Did Move to GameScene View")
        
        cruisingHeight = self.size.height / 7
        
        self.addPlayer(atPosition: CGPoint(x: size.width/2, y: cruisingHeight + self.player.size.height), withSize: CGSize(width: (self.size.width / playerScalingFactor), height: (self.size.height / playerScalingFactor)))

        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: cruisingHeight, width: self.size.width, height: self.size.height - cruisingHeight))
        
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Frame
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        self.swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedUp))
        self.swipeUp.direction = .up
        self.view?.addGestureRecognizer(self.swipeUp)
        
        //background images
        self.addBackground()
        
        //add bWall physics body so we can remove dropping balls
        self.addRemovalNodes()
        
        //setup highscore and current score label nodes
        self.addScoreNodes()
        

    }
    
    
    /*******************************************************
     *
     * _______________ADDING SETUP GAME NODES_______________
     *
     *******************************************************/

    func addEngineImage(){
        
        hasWormholeEngine = SKSpriteNode(imageNamed: "Engine")
        hasWormholeEngine.size = CGSize(width:self.size.width/12, height: self.size.width/12)
        hasWormholeEngine.position = CGPoint(x:self.size.width/2, y:20)
        hasWormholeEngine.zPosition = -4.0;
        hasWormholeEngine.physicsBody?.isDynamic = false
        
        addChild(hasWormholeEngine)
        
    }
    
    func addBackground(){
        
        background1.name = "background"
        background1.size = CGSize(width:self.size.width + 10, height: self.size.height + 20)
        background1.anchorPoint = CGPoint.zero;
        background1.position = CGPoint(x:0, y:0)
        background1.zPosition = -5.0;
        
        background2.name = "background"
        background2.size = CGSize(width:self.size.width + 10, height: self.size.height + 20)
        background2.anchorPoint = CGPoint.zero;
        background2.position = CGPoint(x:0, y:background2.size.height - 1)
        background2.zPosition = -5.0;
        
        
        addChild(background1)
        addChild(background2)
        
    }
    
    
    
    func addPlayer(atPosition: CGPoint, withSize: CGSize){
        
        player = SKSpriteNode(imageNamed: "Woolybear")
        player.name = "player"
        player.size = withSize
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width - 4, height: player.size.height - 4))
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask =  PhysicsCategory.Obstacle | PhysicsCategory.Frame
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.position = atPosition
        player.physicsBody?.allowsRotation = false
        player.zPosition = 1.0;
        
        addChild(player);
        
    }
    
    
    func configureAndAddObstacle() {
        
        
        /*********************************************************************************************************************
         
         To make evading the obstacles possible we need to be a bit more conscious to where they fall on the screen. Basically we
         divide the width by the playerScalingFactor to get the player width (X). So we use playerScalingFactor as the number  of "Chutes" the player could be in. Each chute is exactly the width of the player.size.width and the height of the entire screen.
         
         Obstacles are then set to be C number of chutes wide  (maximum of playerScalingFactor/2 )with it's center in the center  which is (C * X)/2
         
         
         *************************************************************************************************************/
        

        //add Obstacle to Game
        let o: Obstacle = Obstacle(frame: self.frame)
        let obstacle = o.addObstacle()
        
        

        //the radius shouldn't be more than 1/4 the width of the screen. Cast it to an integer to easily identify chute
        if(phaseShift){
            if obstacle.name! == "starNode" {
                
                obstacle.physicsBody?.categoryBitMask = PhysicsCategory.None
                
            }
        }
        
        
        if(wormholeTraveling){
            
            obstacle.size = CGSize(width: obstacle.size.width, height: obstacle.size.height * 2)
            
            if(!wormholeEngine){
                
                obstacle.position = CGPoint(x: obstacle.position.x, y: -(obstacle.position.y - self.size.height))
                
            }
            obstacle.physicsBody?.velocity = CGVector(dx: 0,dy: -flightSpeed * wormholeScalor*2)
        }
        
        addChild(obstacle)

    }
    
    
    //adds node below screen height so that we can remove obstacles when they collide with it
    func addRemovalNodes(){
        
        let removeObstacleNodeBottom = SKSpriteNode()
        let removeObstacleNodeTop = SKSpriteNode()
        
        let size = CGSize(width: 3*self.size.width, height: 20)
        
        removeObstacleNodeBottom.size = size
        removeObstacleNodeBottom.position = CGPoint(x:-self.size.width ,y: -self.size.height)
        removeObstacleNodeBottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
        removeObstacleNodeBottom.name = "removalNodeBottom"
        removeObstacleNodeBottom.physicsBody?.isDynamic = true
        removeObstacleNodeBottom.physicsBody?.affectedByGravity = false
        removeObstacleNodeBottom.physicsBody?.pinned = true
        removeObstacleNodeBottom.physicsBody?.categoryBitMask = PhysicsCategory.Remove
        removeObstacleNodeBottom.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        removeObstacleNodeBottom.physicsBody?.allowsRotation = false
        
        addChild(removeObstacleNodeBottom)

        
        removeObstacleNodeTop.size = size
        removeObstacleNodeTop.position = CGPoint(x:-self.size.width ,y: 2*self.size.height)
        removeObstacleNodeTop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: size.height))
        removeObstacleNodeTop.name = "removalNodeTop"
        removeObstacleNodeTop.physicsBody?.isDynamic = true
        removeObstacleNodeTop.physicsBody?.affectedByGravity = false
        removeObstacleNodeTop.physicsBody?.pinned = true
        removeObstacleNodeTop.physicsBody?.categoryBitMask = PhysicsCategory.Remove
        removeObstacleNodeTop.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        removeObstacleNodeTop.physicsBody?.allowsRotation = false
        
        addChild(removeObstacleNodeTop)
        
    }
    
    
    /*************************************************************
     *
     * ______________________ SCORING LABELS _____________________
     *
     *************************************************************/
    
    
    func addScoreNodes(){

        let defaults = UserDefaults.standard
        self.highScore = defaults.integer(forKey: "highScore")
        
        scoreNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.size.width/2, height: self.size.height/9))
        scoreNode.position = CGPoint(x: self.frame.width, y: scoreNode.frame.height/2);
        
        highScoreNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.size.width/2, height: self.size.height/9))
        highScoreNode.position = CGPoint(x: 0, y: highScoreNode.frame.height/2);
        
        scoreLbl.text = "Score: " + String(describing: self.score)
        scoreLbl.fontColor = UIColor.white
        scoreLbl.fontSize = 16.0
        scoreLbl.fontName = "Arial"
        scoreLbl.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        scoreLbl.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        
        highScoreLbl.text = "High Score: " + String(describing: self.highScore)
        highScoreLbl.fontColor = UIColor.white
        highScoreLbl.fontSize = 16.0
        highScoreLbl.fontName = "Arial"
        highScoreLbl.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        highScoreLbl.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        scoreNode.addChild(scoreLbl)
        highScoreNode.addChild(highScoreLbl)
        
        addChild(scoreNode)
        addChild(highScoreNode)
        
    }
    

    
    /****************************************************************************
     *
     *  __________________________SWIPE SELECTOR METHODS________________________
     *
     *****************************************************************************/
    
    
    //right
    func swipedRight(){
        
        print("swiped Right")
        let distance = self.player.size.width * 3
        
        var jumpRight: SKAction = SKAction()
        
        let jumpTime = 0.1

        if (player.position.x + player.size.width + distance > self.size.width){
            
            jumpRight = SKAction.move(to: CGPoint(x: self.size.width - player.size.width / 2, y: player.position.y), duration: jumpTime)
            
            
        }else{
            
            jumpRight = SKAction.move(to: CGPoint(x: player.position.x + distance, y: player.position.y), duration: jumpTime)
            
        }
        
        player.physicsBody?.velocity = CGVector(dx:0,dy:0)
        
        player.run(jumpRight)
        
    }
    
    
    //left
    func swipedLeft(){
    
        print("swiped Left")
        
        let distance = -self.player.size.width * 3
        
        var jumpLeft: SKAction = SKAction()
        
        let jumpTime = 0.1
        
        if (player.position.x + distance < 0){
            
            jumpLeft = SKAction.move(to: CGPoint(x: player.size.width / 2, y: player.position.y), duration: jumpTime)
            
        }else{
            
            jumpLeft = SKAction.move(to: CGPoint(x: player.position.x + distance, y: player.position.y), duration: jumpTime)
            
        }
        
        player.physicsBody?.velocity = CGVector(dx:0,dy:0)
        
        player.run(jumpLeft)
        
    }
    
    
    //up
     func swipedUp(){
        
        //call this on initial Swipe up
        self.moveBackground = true
        
        
        if(startSwipe){
            
            
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80));
            self.physicsWorld.gravity = CGVector.init(dx: 0, dy: -9.8)
            
            
        }
        
        if(!phaseShift && !startSwipe && !wormholeTraveling){
            
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30));
            self.startPhaseShift()
        }
    }
    
    
    //down
    func swipedDown(){
        
        if(phaseShift){
            
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -30));
            self.stopPhaseShift()
            
        }
    }
    

    /******************************************************************************
    *
    * __________________________ TOUCH DELEGATE METHODS ___________________________
    *
    ********************************************************************************/
    
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    
    /*****************************************************************************
     *
     * _________________________PHYSICS COLLISION METHODS________________________
     *
     *****************************************************************************/
    

    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            
            firstBody = contact.bodyB
            secondBody = contact.bodyA
            
        }
        
        
        if(firstBody.categoryBitMask == PhysicsCategory.Frame && secondBody.categoryBitMask == PhysicsCategory.Player){
            
            if secondBody.node as? SKSpriteNode != nil {
                
                print("Floor Collision")
                playerDidCollideWithFloor()
                
            }
        }
    
        
        if(firstBody.categoryBitMask == PhysicsCategory.Obstacle && secondBody.categoryBitMask == PhysicsCategory.Player){
            
            if  let player = secondBody.node as? SKSpriteNode, let obstacle = firstBody.node as? SKSpriteNode {
                
                print("Obstacle Collision")
                playerDidCollideWithObstacle(player: player, obstacle: obstacle)
                
            }
        }
        
          
            
        if(firstBody.categoryBitMask == PhysicsCategory.Remove && secondBody.categoryBitMask == PhysicsCategory.Obstacle){
            
            if let obstacle = secondBody.node as? SKSpriteNode, let removal = firstBody.node as? SKSpriteNode{
                
                print("Removal Collision")
                obstacleDidCollideWithRemovalNode(obstacle: obstacle, removalWall: removal)
                
            }
            
            
        }
       
        
    }

    
    /*****************************************************************************************************
     *
     *  _____________________________________COLLISION ACTION METHODS____________________________________
     *
     *  - obstacleDidCollideWithRemovalNode -- removed obstacle nodes on contact
     *
     *  - playerDidCollideWithObstacle -- various results based on obstacle name
     *
     *  - playerDidCollideWithFloor -- on first contact it will configure left, right, down swipe gestures
     *
     ******************************************************************************************************/
    
    
    func obstacleDidCollideWithRemovalNode(obstacle: SKSpriteNode, removalWall: SKSpriteNode) {
        
        print("Obstacle Did Collide with Removal Wall, removing")
        obstacle.removeFromParent()
            

    }
    

    func playerDidCollideWithObstacle(player: SKSpriteNode, obstacle: SKSpriteNode) {
        

        if(obstacle.name == "wormholeNode"){
            
            print("Collision with Wormhole")
            
            self.collidedObstacle = obstacle
            
            //slow down the player on wormhole collision or sometimes the bounce is wild
            player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)! * 0.01, dy:(player.physicsBody?.velocity.dy)! * 0.01)
            
            
            self.wormholeEntered()
            
            
        }else if (obstacle.name == "blackholeNode"){
            
            self.collidedObstacle = obstacle
            
            print("Collision with Black Hole")
            
            player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)! * 0.01, dy:(player.physicsBody?.velocity.dy)! * 0.01)
            
            hitBlackholeAnimationSetup(position: obstacle.position)

            
        }else if(obstacle.name == "starNode"){
            
            print("Collision with Star")
            
            self.gameOver()
            
            
        }else if (obstacle.name == "engineNode"){
            
            print("Collision with Engine")
            player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)! * 0.01, dy:(player.physicsBody?.velocity.dy)! * 0.01)
            wormholeEngineAcquired()
            obstacle.removeFromParent()
            
        }
        
    }
    
    
    func playerDidCollideWithFloor() {
        
        if(startSwipe){
            
            startSwipe = false
            
            startAddingObstacles()
            
            self.swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
            self.swipeRight.direction = .right
            self.view?.addGestureRecognizer(self.swipeRight)
            
            
            self.swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
            self.swipeLeft.direction = .left
            self.view?.addGestureRecognizer(self.swipeLeft)
            
            
            self.swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedDown))
            self.swipeDown.direction = .down
            self.view?.addGestureRecognizer(self.swipeDown)

        }
        
    }
    

    
    
    /****************************************************************************
     *
     *  ______________________OBSTACLE CONTROL METHODS___________________________
     *
     *  - startAddingObstacles -- forever repeating SKAction to add obstacles key: dropObstacles
     *  - stopAddingObstacles -- removes the repeating SKAction with key: dropObstacles
     *
     *  - pushCurrentObstacles -- applies y-vel vector to current obstacles in scene
     *  - stopAllObstacles -- sets obstacle velocity to nothing and removes off screen obstacles
     *  - removeAllObstacles -- removes all obstacle children from scene
     *
     *  - stretchCurrentObstacles -- elongates obstacles with a yScale
     *
     *****************************************************************************/
    
    
    
    
    func startAddingObstacles(){
        
        self.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(self.configureAndAddObstacle),
                //adjust ,min/max to increase /decrease frequency of obstacle drop
                SKAction.wait(forDuration: TimeInterval(self.random(min: 0.5, max: 0.7)))
                ])
        ), withKey: "dropObstacles")
    
    }
    
    
    
    func stopAddingObstacles(){
        
        self.removeAction(forKey: "dropObstacles")
        
    }
    
    
    
    func pushCurrentObstacles(scalor: CGFloat, contact: Bool){
        
        for child in self.children{
            
            if (child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode" || child.name == "engineNode"){
                
                child.physicsBody?.isDynamic = true
//                child.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                child.physicsBody?.affectedByGravity = false
                child.physicsBody?.velocity = CGVector(dx: 0, dy: -flightSpeed * wormholeScalor * scalor)
                
                if (contact){
                    
                    child.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
                    
                }else{
                    
                    child.physicsBody?.categoryBitMask = PhysicsCategory.None
                    
                }
            }
        }
    }

    
    func stopAllObstacles (){
        
        for child in self.children{
            
            if (child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode" || child.name == "engineNode"){
                
                
                if(child.position.y > self.size.height + player.size.height || child.position.y < self.size.height/3){
                    
                    print("removing child from parent")
                    child.removeFromParent()
                    
                }else{
                    
                    child.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    child.physicsBody?.isDynamic = false
                    
                }
            }
            
        }
    
    }
    
    
    
    
    /*************************************************************************************************************************
     *
     * __________________________________________WORMHOLE METHODS______________________________________
     *
     *  -wormholeEngineAcquired -- sets global wormholeEngine to true and adds the engine sprite to status bar
     *
     *  - wormholeEntered -- fired at collision time with wormhole. Configures world physics for travel
     *  - wormholeTravel -- fired after player and wormhole are small enough, starts time and starts adding elongated obstacles
     *
     *
     *  - exitWormhole -- called after wormhole timer completes, freezes scene and set up physics for the animation
     *  - wormholeExited -- called after wormhole is removed from parent. Re-enables normal playing physics and interactions
     *
     *  - enterWormholeAnimationSetup -- sets up radialGravityField for animation
     *  - exitWormholeAnimationSetup -- adds player and wormhole back as children at the proper locations with proper size
     *
     **************************************************************************************************************************/
    
    
    
    func wormholeEngineAcquired(){
        
        self.addEngineImage()
        self.wormholeEngine = true
        
    }
    
    
    
    /**********************
     * --------------------
     * -- WORMHOLE ENTER --
     * --------------------
     **********************/
    
    
    func wormholeEntered(){
        
        collidedObstacle.name = "collidedWormhole"
        let wormholeYVelocity:CGFloat = 20
        
        moveBackground = false
        
        stopAddingObstacles()
        stopAllObstacles()
        
        collidedObstacle.physicsBody?.categoryBitMask = PhysicsCategory.None
        
        collidedObstacle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = true
        
        if(wormholeEngine){
            
            flightSpeed = wormholeYVelocity
            
        }else{

            flightSpeed = -wormholeYVelocity
        }
        
        exitPoint = player.position
        enterWormholeAnimationSetup(position: self.collidedObstacle.position)
    }

    
    func startWormholeTravel(){
        
        wormholeTraveling = true
        pushCurrentObstacles(scalor: 2, contact:false)
        startAddingObstacles()
        moveBackground = true
        
        wormholeTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(exitWormhole), userInfo: nil, repeats: false)
        
    }
    
    /**********************
     *
     * WORMHOLE EXIT
     *
     **********************/
    
    
    func wormholeExited(){
        
        
        wormholeEngine = false
        
        if(wormholeEngine){
            hasWormholeEngine.removeFromParent()
        }
        
        wormholeTraveling = false
        moveBackground = true
        flightSpeed = 9.0
        
        //set world physics back to normal

        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.affectedByGravity = true
        
        pushCurrentObstacles(scalor: 1, contact: true)
        startAddingObstacles()

    }
    
    
    
    
    func exitWormhole(){
        
        wormholeTimer.invalidate()
        
        stopAddingObstacles()
        stopAllObstacles()
        
        moveBackground = false
        wormholeTraveling = false
        
        exitWormholeAnimationSetup()
        
    }
    
    
    /**********************
     *
     * WORMHOLE ANIMATIONS
     *
     **********************/
    
    
    func enterWormholeAnimationSetup(position: CGPoint){
        
        field = SKFieldNode.radialGravityField()
        shrinkPlayer = true
        
        field.position = position
        field.falloff = -1
        field.smoothness = 4
        field.strength = 6
        
        addChild(field)
    
    }
    
    
    func exitWormholeAnimationSetup(){
        
        growPlayer = true
        
        collidedObstacle.position = exitPoint
        
        collidedObstacle.size = CGSize(width: (self.size.width / playerScalingFactor) * 0.05, height: (self.size.height / playerScalingFactor) * 0.05)
        
        
        player.size = CGSize(width: (self.size.width / playerScalingFactor) * 0.05, height: (self.size.height / playerScalingFactor) * 0.05)
        player.position = CGPoint(x: exitPoint.x + player.size.width/2, y: exitPoint.y)
        
        
        addChild(player)
        addChild(collidedObstacle)

    }
    
    
    /**************************************************
     *
     * BLACKHOLE ANIMATION
     *
     ***************************************************/
    
    
    func hitBlackholeAnimationSetup(position: CGPoint){

        field = SKFieldNode.radialGravityField()
        
        moveBackground = false
        
        stopAddingObstacles()
        stopAllObstacles()
        
        
        shrinkPlayer = true
        hitBlackhole = true
        
        
        collidedObstacle.name = "collidedBlackhole"
        collidedObstacle.physicsBody?.categoryBitMask = PhysicsCategory.None
        collidedObstacle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = true
        
        
        field.position = position
        field.falloff = -1
        field.smoothness = 4
        field.strength = 10

        
        addChild(field)
        
    }
    
    
    /*************************
     *
     * PHASE SHIFT METHODS
     *
     *************************/
    
    
    //lets the bear pass through stars
    func startPhaseShift(){
        print("start phase shift")
        
        self.phaseShift = true
        self.slowPulse = true
        
        BeginPulsingSwitch()
        
        Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(BeginPulsingSwitch), userInfo: nil, repeats: false)
        
        phaseTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(stopPhaseShift), userInfo: nil, repeats: false)
        
        for child in self.children{
            
            //set current star nodes physicsBody so player will pass through them
            if(child.name == "starNode"){
                
                print(child.name! as String)
                
                child.physicsBody?.categoryBitMask = PhysicsCategory.None

                
            }
        }
    }
    
    
    func stopPhaseShift (){
        
        self.phaseShift = false
        
        phaseTimer.invalidate()
        pulseTimer.invalidate()
        
        self.player.run(SKAction.fadeIn(withDuration: 0.1))
        
        for child in self.children{
            
            //set current star nodes physicsBody so player will pass through them
            if(child.name == "starNode"){
                print(child.name! as String)
                
                child.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
                
            }
        }
    }
    
    
    func BeginPulsingSwitch() {
        
        // Something after a delay
        let fadeInOut = true
        
        if(self.slowPulse){
            
            self.slowPulse = false
            
            pulseTimer(pulseDuration:0.5, fade:fadeInOut)
            
            
        }else{
            
            pulseTimer.invalidate()
            pulseTimer(pulseDuration:0.2, fade:fadeInOut)
            
        }
        
    }
    
    
    func pulseTimer(pulseDuration: CGFloat, fade: Bool){
        
        var fadeInOut = fade
        pulseTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(pulseDuration), repeats: true) { timer in
            
            if (fadeInOut){
                
                self.player.run(SKAction.fadeOut(withDuration: TimeInterval(pulseDuration)))
                fadeInOut = false
                
                
            }else{
                
                self.player.run(SKAction.fadeIn(withDuration: TimeInterval(pulseDuration)))
                fadeInOut = true
            }
        }
    }
    
    
    /****************************************************************************
     *
     * ____________________ SKVIEW UPDATE DELEGATE METHOD _______________________
     *
     *****************************************************************************/
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        /************************************
         *
         * __________ SCORE KEEPING _________
         *
         * ---- Add scoreNumber to score ----
         *
         ************************************/
        
        var scoreNumber: Int = 1
        
        if(wormholeTraveling && !wormholeEngine){
                
            scoreNumber = -1
            
        }
        
        
        let scoreDistance = abs(scrollCounter - background1.position.y)
        
        if (scoreDistance > self.size.height / (playerScalingFactor)){
            
            scrollCounter = background1.position.y
            updateScore(scoreNumber: scoreNumber)
            scoreLbl.text = "Score: " + String(describing: self.score)
            
        }
        
        
        /***********************
         *
         * WORMHOLE ANIMATIONS
         *
         ***********************/
        
        
        if(shrinkPlayer){
            
            
            //if obstacle is not a black hole, stretch the obstacles in view
            if(!hitBlackhole){
                for child in self.children {
                    
                    if((child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode" || child.name == "engineNode") && (child.position.y < self.size.height && child.position.y > 0)){
                        
                        if(child.yScale < 2){
                            child.yScale  = child.yScale + 0.01
                            child.xScale = child.xScale + 0.005
                        }
                    }
                }
            }
            
            
            if(player.size.height > self.size.height / 45  && player.size.width > self.size.width / 45){
                
                player.size = CGSize(width: player.size.width - player.size.width/45 ,height: player.size.height - player.size.height/45)

                
            }else if (hitBlackhole){
                
                self.gameOver()
                
            }else{
            
            
                if (collidedObstacle.size.height > self.size.height / 45  && collidedObstacle.size.width > self.size.width / 45){
                    
                    collidedObstacle.size = CGSize(width: collidedObstacle.size.width - wormholeInc ,height: collidedObstacle.size.height - wormholeInc)
                    
                }else{
                    
                    collidedObstacle.removeFromParent()
                    player.removeFromParent()
                    field.removeFromParent()
                    
                    shrinkPlayer = false
                    startWormholeTravel()
                    
                }
            }
        }
        
        
        if(growPlayer){
            
            //shrink obstacles in view
            for child in self.children {
                
                if((child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode" || child.name == "engineNode") && (child.position.y < self.size.height && child.position.y > 0)){
                    
                    if(child.yScale > 0.5){
                        child.yScale  = child.yScale - 0.01
                    }
                    
                    
                }
            }
            
            
            //player/wormhole growth
            if (collidedObstacle.size.width < (self.size.width / playerScalingFactor ) * 3) {
                
                collidedObstacle.size = CGSize(width: collidedObstacle.size.width + wormholeInc ,height: collidedObstacle.size.height + wormholeInc)
                
            }else{
                
                if(player.size.height < self.size.height / playerScalingFactor  && player.size.width < self.size.width / playerScalingFactor){
                
                    player.size = CGSize(width: player.size.width + 0.5, height: player.size.height + 1.0)
                
                }else{
                
                    player.size = CGSize(width: (self.size.width / playerScalingFactor), height: (self.size.height / playerScalingFactor))
                    
                    growPlayer = false
                    shrinkWormhole = true
                
                }
                
            }
        }
        
        
        if(shrinkWormhole){
            
            if (collidedObstacle.size.width > (player.size.width) / 45) {
                
                collidedObstacle.size = CGSize(width: collidedObstacle.size.width - wormholeInc ,height: collidedObstacle.size.height - wormholeInc)
                
            }else{
                
                collidedObstacle.removeFromParent()
                shrinkWormhole = false
                
                wormholeExited()
                
            }
        }
        
        
        /******************************************
         *
         * BACKGROUND CONTROL
         *
         * move the background for the flying effect
         *
         ******************************************/
        
        
        if moveBackground {
            
            if (wormholeEngine || !wormholeTraveling){
                
                background1.position = CGPoint(x: background1.position.x, y: background1.position.y - flightSpeed)
                background2.position = CGPoint(x:background2.position.x, y:background2.position.y - flightSpeed)
            
                if(background1.position.y < -background1.size.height){
                    
                    background1.position = CGPoint(x:background2.position.x, y:background1.position.y + 2*self.size.height)
                    scrollCounter = background1.position.y

                }
            
                if(background2.position.y < -background2.size.height){
                    
                    background2.position = CGPoint(x:background1.position.x, y:background2.position.y + 2*self.size.height)

                
                }
                
            }else{
                    
                background1.position = CGPoint(x: background1.position.x, y: background1.position.y - flightSpeed)
                background2.position = CGPoint(x:background2.position.x, y:background2.position.y - flightSpeed)
                
                if(background1.position.y > background1.size.height){
                    
                    background1.position = CGPoint(x:background2.position.x, y:(background1.position.y - background1.size.height) - self.size.height)
                    scrollCounter = background1.position.y
                    
                }
                    
                if(background2.position.y > background2.size.height){
                        
                    background2.position = CGPoint(x:background1.position.x, y: (background2.position.y - background2.size.height) - self.size.height)

                }
            }
        }
    }
    
    
    
    
    
    /***********************************
     *
     * RANDOM NUMBER GENERATION
     *
     ************************************/
    
    
    //produces a random CGFloat
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    
    //produces random CGFloat within range
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    
    
    
    
    /****************************************************************************
     *
     *  ENDGAME, NAVIGATION AND SCORE METHODS
     *
     *****************************************************************************/
    

    
    
    override func willMove(from view: SKView) {
        if view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                if let recognizer = gesture as? UISwipeGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    
    func updateScore(scoreNumber: Int){
        
        self.score = score + scoreNumber
        
        
    }
    
    
    
    //GAME OVER
    
    func gameOver(){
        
//        stopAllObstacles()
        stopAddingObstacles()
        engineTimer.invalidate()
        
        self.moveBackground = false
        
        self.goToGameOverScene()
        
    }
    
    //will goto the game over scene
    func goToGameOverScene(){
        
        let defaults = UserDefaults.standard
        
        defaults.set(self.score, forKey: "score")
        
        defaults.synchronize()
        
        let gameOverScene:GameOverScene = GameOverScene(size: self.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 2.0) // create type of transition (you can check in documentation for more transtions)
        
        gameOverScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(gameOverScene, transition: transition)
        
        
    }
    
    

    
}
