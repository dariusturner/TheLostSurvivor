//
//  GameScene.swift
//  TheLostSurvivor
//
//  Created by Darius Turner on 1/25/17.
//  Copyright © 2017 DariusTurner. All rights reserved.
//

import GoogleMobileAds
import Firebase
import SpriteKit

struct PhysicsCategories {
    static let spaceShip : UInt32 = 0x1 << 1
    static let LaserTraps : UInt32 = 0x1 << 2
    static let ground : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var startLbl = SKSpriteNode()
    var background = SKSpriteNode()
    var spaceShip = SKSpriteNode()
    var ground = SKSpriteNode()
    
    var trapPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLbl = SKLabelNode()
    
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene() {
        
        self.physicsWorld.contactDelegate = self
        
        startLbl = SKSpriteNode(imageNamed: "TapToPlay")
        startLbl.position = CGPoint(x: 0, y: self.frame.height / 4)
        startLbl.size = CGSize(width: 400, height: 150)
        startLbl.zPosition = 6
        self.addChild(startLbl)
        
        scoreLbl.position = CGPoint(x: 0, y: self.frame.height / 2.5)
        scoreLbl.fontSize = CGFloat(100)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 4
        self.addChild(scoreLbl)
        
        background = SKSpriteNode(imageNamed: "SpaceBackground")
        background.size = CGSize(width: self.frame.width, height: self.frame.height)
        self.addChild(background)
        
        ground = SKSpriteNode(imageNamed: "LaserTrap")
        ground.size = CGSize(width: 1280, height: 200)
        ground.position = CGPoint(x: 100 - self.frame.width / 4, y: 0 - self.frame.height / 2.5 - 50)
        
        ground.zPosition = 3
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategories.spaceShip
        ground.physicsBody?.contactTestBitMask = PhysicsCategories.spaceShip
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        
        self.addChild(ground)
        
        spaceShip = SKSpriteNode(imageNamed: "Spaceship")
        spaceShip.size = CGSize(width: 150, height: 170)
        spaceShip.position = CGPoint(x: -20, y: 0)
        
        spaceShip.zPosition = 2
        
        spaceShip.physicsBody = SKPhysicsBody(circleOfRadius: spaceShip.frame.height / 2)
        spaceShip.physicsBody?.categoryBitMask = PhysicsCategories.spaceShip
        spaceShip.physicsBody?.collisionBitMask = PhysicsCategories.LaserTraps | PhysicsCategories.ground
        spaceShip.physicsBody?.contactTestBitMask = PhysicsCategories.LaserTraps | PhysicsCategories.ground | PhysicsCategories.Score
        spaceShip.physicsBody?.affectedByGravity = false
        spaceShip.physicsBody?.isDynamic = true
        
        self.addChild(spaceShip)
        
    }
    
    override func didMove(to view: SKView) {
        
        createScene()
        
}
    
    func createBTN() {
        
        restartBTN = SKSpriteNode(imageNamed: "RestartBTN")
        restartBTN.size = CGSize(width: 401, height: 201)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 5
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        restartBTN.run(SKAction.scale(to: 1.0, duration: 1.5))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategories.Score && secondBody.categoryBitMask == PhysicsCategories.spaceShip || firstBody.categoryBitMask == PhysicsCategories.spaceShip && secondBody.categoryBitMask == PhysicsCategories.Score {
           
            score += 1
            
            scoreLbl.text = "\(score)"
            
        }
        
        else if firstBody.categoryBitMask == PhysicsCategories.spaceShip && secondBody.categoryBitMask == PhysicsCategories.LaserTraps || firstBody.categoryBitMask == PhysicsCategories.LaserTraps && secondBody.categoryBitMask == PhysicsCategories.spaceShip {
            
            if died == false {
                died = true
                createBTN()
            }
            
        }
        
        
        else if firstBody.categoryBitMask == PhysicsCategories.spaceShip && secondBody.categoryBitMask == PhysicsCategories.ground || firstBody.categoryBitMask == PhysicsCategories.ground && secondBody.categoryBitMask == PhysicsCategories.spaceShip {
            
            if died == false {
                died = true
                createBTN()
            }
            
        }
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            
            gameStarted = true
            
            startLbl.isHidden = true
            
            spaceShip.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createTraps()
                
            })
            
            let delay = SKAction.wait(forDuration: 1.8)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + trapPair.frame.width)
            let moveTraps = SKAction.moveBy(x: -distance - 550, y: 0, duration: TimeInterval(0.0046 * distance))
            let removeTraps = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveTraps, removeTraps])
            
            spaceShip.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            spaceShip.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
            
        } else {
            
            if died == true {
                
            }
            else {
                spaceShip.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                spaceShip.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
            }
            
        }
        
        
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if died == true {
                if restartBTN.contains(location){
                    restartScene()
                }
            }
            
        }
        
        
}
    
    func createTraps() {
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 3, height: 300)
        scoreNode.position = CGPoint(x: self.frame.width / 2 + 280, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategories.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategories.spaceShip
        
        trapPair = SKNode()
        
        let topTrap = SKSpriteNode(imageNamed: "LaserTrap")
        let btmTrap = SKSpriteNode(imageNamed: "LaserTrap")
        
        topTrap.position = CGPoint(x: self.frame.width / 2 + 280, y: 0 + 400)
        btmTrap.position = CGPoint(x: self.frame.width / 2 + 280, y: 0 - 400)
        
        topTrap.setScale(2)
        btmTrap.setScale(2)
        
        topTrap.physicsBody = SKPhysicsBody(circleOfRadius: topTrap.frame.height / 3)
        topTrap.physicsBody?.categoryBitMask = PhysicsCategories.LaserTraps
        topTrap.physicsBody?.collisionBitMask = PhysicsCategories.spaceShip
        topTrap.physicsBody?.contactTestBitMask = PhysicsCategories.spaceShip
        topTrap.physicsBody?.affectedByGravity = false
        topTrap.physicsBody?.isDynamic = false
        
        btmTrap.physicsBody = SKPhysicsBody(circleOfRadius: btmTrap.frame.height / 3)
        btmTrap.physicsBody?.categoryBitMask = PhysicsCategories.LaserTraps
        btmTrap.physicsBody?.collisionBitMask = PhysicsCategories.spaceShip
        btmTrap.physicsBody?.contactTestBitMask = PhysicsCategories.spaceShip
        btmTrap.physicsBody?.affectedByGravity = false
        btmTrap.physicsBody?.isDynamic = false
        
        trapPair.addChild(topTrap)
        trapPair.addChild(btmTrap)
        
        trapPair.zPosition = 1
        
        let randomPostition = CGFloat.random(min: -250, max: 250)
        trapPair.position.y = trapPair.position.y + randomPostition
        trapPair.addChild(scoreNode)
        
        trapPair.run(moveAndRemove)
        
        self.addChild(trapPair)
        
    }
    
 
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }

}
