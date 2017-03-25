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
    static let Remove    : UInt32 = 0b1
    static let Floor     : UInt32 = 0b10
    static let Obstacle  : UInt32 = 0b11
    static let Player    : UInt32 = 0b100
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    

    //bear sprite
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "Woolybear")
    
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
    var collidedWormhole: SKSpriteNode
    
    //wormhole radial gravity field
    let field: SKFieldNode
    
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
        collidedWormhole = SKSpriteNode()
        wormholeEngine = false
        shrinkPlayer = false
        growPlayer = false
        wormholeTraveling = false
        shrinkWormhole = false
        
        wormholeInc = 2.0
        wormholeScalor = 45.0
        wormholeTimer = Timer()
        exitPoint = CGPoint()
        
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
        
        cruisingHeight = self.size.height / 5
        
        self.addPlayer(atPosition: CGPoint(x: size.width/2, y: cruisingHeight + self.player.size.height), withSize: CGSize(width: (self.size.width / playerScalingFactor), height: (self.size.height / playerScalingFactor)))

        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: cruisingHeight, width: self.size.width, height: self.size.height - cruisingHeight))
        
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
        
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
     * ADDING SETUP GAME NODES
     *
     *******************************************************/

    
    func addBackground(){
        
        background1.name = "background"
        background1.size = CGSize(width:self.size.width + 10, height: self.size.height + 20)
        background1.anchorPoint = CGPoint.zero;
        background1.position = CGPoint(x:0, y:0)
        background1.zPosition = -5.0;
        addChild(background1)
        
        
        background2.name = "background"
        background2.size = CGSize(width:self.size.width + 10, height: self.size.height + 20)
        background2.anchorPoint = CGPoint.zero;
        background2.position = CGPoint(x:0, y:background2.size.height - 1)
        background2.zPosition = -5.0;
        addChild(background2)
        
    }
    
    
    
    func addPlayer(atPosition: CGPoint, withSize: CGSize){
        
        player.name = "player"
        
        player.size = withSize
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width - 4, height: player.size.height - 4))

        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask =  PhysicsCategory.Floor
        player.physicsBody?.collisionBitMask = PhysicsCategory.Floor
        
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
        
        
        //each obstacle type gets it's own random sizing framework
        if obstacle.name! == "starNode" {
            
            //the radius shouldn't be more than 1/4 the width of the screen. Cast it to an integer to easily identify chute
            if(self.phaseShift){
                    
                obstacle.physicsBody?.categoryBitMask = PhysicsCategory.None
                obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.None | PhysicsCategory.Remove
                obstacle.physicsBody?.collisionBitMask = PhysicsCategory.None | PhysicsCategory.Remove
                
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
        
        let size = CGSize(width: 3 * self.size.width, height: 20)
        
        removeObstacleNodeBottom.size = size
        removeObstacleNodeBottom.position = CGPoint(x:-self.size.width ,y: -self.size.height)
        removeObstacleNodeBottom.name = "removalNode"
        removeObstacleNodeBottom.physicsBody?.isDynamic = false

        removeObstacleNodeBottom.physicsBody?.categoryBitMask = PhysicsCategory.Remove
        removeObstacleNodeBottom.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle
        removeObstacleNodeBottom.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        
        addChild(removeObstacleNodeBottom)

        
        removeObstacleNodeTop.size = size
        removeObstacleNodeTop.position = CGPoint(x:-self.size.width ,y: 2*self.size.height)
        removeObstacleNodeTop.name = "removalNode"
        removeObstacleNodeTop.physicsBody?.isDynamic = false
        
        removeObstacleNodeTop.physicsBody?.categoryBitMask = PhysicsCategory.Remove
        removeObstacleNodeTop.physicsBody?.collisionBitMask = PhysicsCategory.Obstacle
        removeObstacleNodeTop.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        
        addChild(removeObstacleNodeTop)
        
    }
    
    /*************************************************************
     *
     * SCORING LABELS
     *
     ************************************************************/
    
    
    
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
     *  SWIPE SELECTOR METHODS
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
        if(startSwipe){
            
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80));
            
            self.physicsWorld.gravity = CGVector.init(dx: 0, dy: -9.8)
            
        }
        
        if(!phaseShift && moveBackground && !wormholeTraveling){
            
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50));
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
    

    /*************************************************************************************
    *
    * TOUCH DELEGATE METHODS
    *
    **************************************************************************************/
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    
    /****************************************************************************
     *
     *  PHYSICS COLLISION METHODS
     *
     *****************************************************************************/
    

    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactPoint = contact.contactPoint
        
        print(contactPoint)
        
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
        if ((firstBody.categoryBitMask & PhysicsCategory.Floor != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if  (secondBody.node as? SKSpriteNode != nil) {
                
                playerDidCollideWithCruisingHeight()
                
            }
        }
        
        
        //Star Collision
        if ((firstBody.categoryBitMask & PhysicsCategory.Obstacle != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if  let player = secondBody.node as? SKSpriteNode, let ball = firstBody.node as? SKSpriteNode {
                
                playerDidCollideWithObstacle(player: player, obstacle: ball)
                
            }
        }
            
       //Removal Collision
       if ((firstBody.categoryBitMask & PhysicsCategory.Remove != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Obstacle != 0)) {
            if let obstacle = firstBody.node as? SKSpriteNode, let removal = secondBody.node as? SKSpriteNode{
                
                obstacleDidCollideWithRemovalNode(obstacle: obstacle, removalWall: removal)
                
            }
        }
        
    }

    
    /****************************************************************************
     *
     *  COLLISION ACTION METHODS
     *
     *****************************************************************************/
    
    
    func obstacleDidCollideWithRemovalNode(obstacle: SKSpriteNode, removalWall: SKSpriteNode) {
        
        print("Obstacle Did Collide with Removal Wall, removing")
        obstacle.removeFromParent()
            

    }
    

    func playerDidCollideWithObstacle(player: SKSpriteNode, obstacle: SKSpriteNode) {
        
        
        if(obstacle.name == "wormholeNode"){
            
            print("Collision with Wormhole")
            
            self.collidedWormhole = obstacle
            
            //slow down the player on wormhole collision or sometimes the bounce is wild
            player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)! * 0.01, dy:(player.physicsBody?.velocity.dy)! * 0.01)
            
            
            self.wormholeEntered()
            
            
        }else if (obstacle.name == "blackholeNode"){
            
            print("Collision with Black Hole")
            hitBlackholeAnimationSetup(position: obstacle.position)
            self.gameOver()
            
        }else if(obstacle.name == "starNode"){
            
            print("Collision with Star")
            
            self.gameOver()
            
        }else if (obstacle.name == "engineNode"){
            
            print("Collision with Engine")
            wormholeEngineAcquired()
            obstacle.removeFromParent()
            
        }
    }
    

    
    func playerDidCollideWithCruisingHeight() {
        

        if(startSwipe){
            
            startSwipe = false
            
            self.moveBackground = true
            
            startAddingObstacles()
            startDroppingEngines()
            
            
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
     *  OBSTACLE CONTROL METHODS
     *
     *****************************************************************************/
    
    
    func startDroppingEngines(){
        
        engineTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(6.0), repeats: true) { timer in
            // Add your code here
            
            let o = Obstacle(frame: self.frame)
            let engine = o.addEngine()
            
            self.addChild(engine)
            
        }
        
    }
    
    func stopDroppingEngines(){
        
        engineTimer.invalidate()
        
    }
    
    
    func startAddingObstacles(){
        
        
        self.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(self.configureAndAddObstacle),
                //adjust ,min/max to increase /decrease frequency of obstacle drop
                SKAction.wait(forDuration: TimeInterval(self.random(min: 0.5, max: 0.7)))
                ])
        ), withKey: "drop")
    
    }
    
    
    
    
    func stopAddingObstacles(){
        
        self.removeAction(forKey: "drop")
        
    }
    
    
    func pushCurrentObstacles(scalor: CGFloat){
        
        for child in self.children{
            
            if (child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode"){
                
                child.physicsBody?.isDynamic = true
                child.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                child.physicsBody?.affectedByGravity = false
                child.physicsBody?.velocity = CGVector(dx: 0, dy: -flightSpeed * wormholeScalor * scalor)
                
            }
        }
    }

    
    func stopAllObstacles (){
        
        for child in self.children{
            
            if (child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode"){
                
                
                if(child.position.y > self.size.height || child.position.y < cruisingHeight){
                    
                    print("removing child from parent")
                    child.removeFromParent()
                    
                }else{
                    
                    child.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    child.physicsBody?.isDynamic = false
                    
                }
//
            }
            
        }
    
    }
    
    

    func stretchObstacles(){
        
        for child in self.children {
                
                
            if((child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode") && (child.position.y < self.size.height && child.position.y > 0)){
                
                
                
                
            }
        }
    }
    
    
    
    func restoreObstacleSphere(){
        
        for child in self.children{
            
            if ((child.name == "wormholeNode" || child.name == "blackholeNode" || child.name == "starNode") && (child.position.y < self.size.height && child.position.y > 0)){
                
                
                
            }
        }
    }
    
    
    /*******************************
     *
     * WORMHOLE METHODS
     *
     *******************************/
    
    
    
    func wormholeEngineAcquired(){
        
        self.wormholeEngine = true
        
    }
    
    
    func wormholeEntered(){
        
        collidedWormhole.name = "collidedWormhole"
        let wormholeYVelocity:CGFloat = 20
        
        moveBackground = false
        
        stopAddingObstacles()
        stopAllObstacles()
        stopDroppingEngines()
        
        collidedWormhole.physicsBody?.categoryBitMask = PhysicsCategory.None
        collidedWormhole.physicsBody?.collisionBitMask = PhysicsCategory.None
        collidedWormhole.physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        collidedWormhole.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = true
        
        if(wormholeEngine){
            
            flightSpeed = wormholeYVelocity
            
        }else{

            flightSpeed = -wormholeYVelocity
        }
        
        exitPoint = player.position
        enterWormholeAnimationSetup(position: self.collidedWormhole.position)
    }

    
    func startWormholeTravel(){
        
        wormholeTraveling = true
        pushCurrentObstacles(scalor: 2)
        startAddingObstacles()
        moveBackground = true
        
        wormholeTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(exitWormhole), userInfo: nil, repeats: false)
        
    }
    
    func wormholeExited(){
        
        
        wormholeEngine = false
        wormholeTraveling = false
        moveBackground = true
        flightSpeed = 9.0
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width - 4, height: player.size.height - 4))
        
        pushCurrentObstacles(scalor: 1)
        startAddingObstacles()
        startDroppingEngines()
    }
    
    
    func exitWormhole(){
        
        wormholeTimer.invalidate()
        
        self.stopAddingObstacles()
        self.stopAllObstacles()
        
        moveBackground = false
        wormholeTraveling = false
        
        exitWormholeAnimationSetup()
        
    }
    
    
    /**************************************************
     *
     * WORMHOLE ANIMATION
     *
     ***************************************************/
    
    
    func enterWormholeAnimationSetup(position: CGPoint){
        
        shrinkPlayer = true
        
        field.position = position
        field.falloff = -1
        field.smoothness = 4
        field.strength = 15
//        field.animationSpeed = 40
        
        addChild(field)
    
    }
    
    
    func exitWormholeAnimationSetup(){
        
        growPlayer = true
        
        collidedWormhole.position = exitPoint
        
        collidedWormhole.size = CGSize(width: (self.size.width / playerScalingFactor) * 0.05, height: (self.size.height / playerScalingFactor) * 0.05)
        
        self.addPlayer(atPosition: exitPoint, withSize: CGSize(width: (self.size.width / playerScalingFactor) * 0.05, height: (self.size.height / playerScalingFactor) * 0.05))
        
        addChild(collidedWormhole)

    }
    
    
    /**************************************************
     *
     * BLACKHOLE ANIMATION
     *
     ***************************************************/
    
    
    func hitBlackholeAnimationSetup(position: CGPoint){

        shrinkPlayer = true
        
        field.position = position
        field.falloff = -1
        field.smoothness = 4
        field.strength = 40
//        field.animationSpeed = 40
        
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
                child.physicsBody?.collisionBitMask = PhysicsCategory.None
                child.physicsBody?.contactTestBitMask = PhysicsCategory.None
                
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
                child.physicsBody?.collisionBitMask = PhysicsCategory.Player
                child.physicsBody?.contactTestBitMask = PhysicsCategory.Player
                
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
            // Add your code here
            
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
     *  SKVIEW UPDATE DELEGATE METHOD
     *
     *****************************************************************************/
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        /************************************
         *
         * SCORE KEEPING
         *
         * Add scoreNumber to score
         *
         ************************************/
        
        var scoreNumber: Int = 1
        
        if(wormholeTraveling && !wormholeEngine){
                
            scoreNumber = -1
            
        }
        let scoreDistance = abs(scrollCounter - background1.position.y)
        
        
        
        if (scoreDistance > self.size.height / (playerScalingFactor / 2)){
            
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
            
            if(player.size.height > self.size.height / 45  && player.size.width > self.size.width / 45){
                
                player.size = CGSize(width: player.size.width - 0.6 ,height: player.size.height - 1.0)

                
            }else{
                
                if (collidedWormhole.size.height > self.size.height / 45  && collidedWormhole.size.width > self.size.width / 45){
                    
                    collidedWormhole.size = CGSize(width: collidedWormhole.size.width - wormholeInc ,height: collidedWormhole.size.height - wormholeInc)
                    
                }else{
                    
                    collidedWormhole.removeFromParent()
                    player.removeFromParent()
                    field.removeFromParent()
                    
                    shrinkPlayer = false
                    startWormholeTravel()
                    
                }
            }
        }
        
        
        if(growPlayer){
            
            
            if (collidedWormhole.size.width < (self.size.width / playerScalingFactor ) * 3) {
                
                collidedWormhole.size = CGSize(width: collidedWormhole.size.width + wormholeInc ,height: collidedWormhole.size.height + wormholeInc)
                
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
            
            if (collidedWormhole.size.width > (player.size.width) / 45) {
                
                collidedWormhole.size = CGSize(width: collidedWormhole.size.width - wormholeInc ,height: collidedWormhole.size.height - wormholeInc)
                
            }else{
                
                collidedWormhole.removeFromParent()
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
        
        stopAllObstacles()
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
