//                                                              $
//  GameScene.swift                                             $
//  spriteTest                                                  $
//                                                              $
//  Created by Vikram Mullick on 6/12/16.                       $
//  Copyright (c) 2016 Vikram Mullick. All rights reserved.     $
//                                                              $
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

import SpriteKit //Sprite Kit
struct PhysicsCat//used to assign references to different surfaces (Cat is short for Category. It's not a cat ^-^)
{
    static let slope: UInt32 = 0x1 << 1 //reference for slope
    static let sprite: UInt32 = 0x1 << 2//reference for sprite
}

class GameScene: SKScene {
    let cam = SKCameraNode()//camera is define so we can move with the sprite
    let sprite = SKSpriteNode(imageNamed:"happy")//sprite (This is where we also define what image will be used)
    let sun = SKSpriteNode(imageNamed:"sun")//sun (This is where we also define what image will be used)

    var paths : [UIBezierPath] = [UIBezierPath(),UIBezierPath()] // array of paths for the hills to follow. There always will be only two
    var slopes : [SKShapeNode] = [SKShapeNode(),SKShapeNode()] //array of nodes for the paths
    
    var lastCriticalPoint : CGFloat = 100

    override func didMoveToView(view: SKView) {

        view.showsPhysics = false //used if we want to see the physics bodies (debug)
        backgroundColor = UIColor.blueColor()//set background color
        setupSun()// adds sun
        setupDefaultPath()//defines default paths
        setupSlope(slopes[0],x: 0, newPath: paths[0])//sets up node 1
        setupSlope(slopes[1],x: self.frame.width, newPath: paths[1])// sets up node 2
        setupSprite()//sets up sprite
        setupCamera()//sets up camera
        


        
     
    }
    func setupSlope(slope : SKShapeNode, x : CGFloat, newPath : UIBezierPath)//used to assign properties to slopes
    {
        slope.position = CGPointMake(x, 0)//set position at given x value
        slope.zRotation = 0.0//no rotation
        slope.path = newPath.CGPath//sets path as given path
        slope.physicsBody=SKPhysicsBody(edgeChainFromPath: newPath.CGPath)//sets physicsbody to path
        slope.fillColor = UIColor.whiteColor()//white color for snow
        slope.strokeColor = UIColor.whiteColor()//sprite color as snow
        slope.lineWidth = 10//makes slope closer to ball
        slope.physicsBody?.categoryBitMask = PhysicsCat.slope//sets reference to slope
        slope.physicsBody?.collisionBitMask = PhysicsCat.sprite//sets to interact with sprite
        slope.physicsBody?.contactTestBitMask = PhysicsCat.sprite//sets to interact with sprite
        slope.physicsBody?.affectedByGravity=false//we don't want the slope to be falling
        slope.physicsBody?.allowsRotation=false//no rotation
        slope.physicsBody?.dynamic=false// okay so this line makes the two above lines sorta redundant but fuck it
        slope.physicsBody?.restitution=0.0// reduces bounciness of ball
        slope.physicsBody?.friction=0//minimizes friction
        slope.physicsBody?.linearDamping=0//less energy loss
        slope.physicsBody?.angularDamping=0//less energy loss
        addChild(slope)//add to gamescene
    }
    func setupDefaultPath()// defines starting paths for first two frames
    {
        //create path for frame 1
        paths[0].moveToPoint(CGPointMake(0, -self.frame.height/2))
        paths[0].addLineToPoint(CGPointMake(0, 0))
        paths[0].addCurveToPoint(CGPointMake(self.frame.width, 0), controlPoint1: CGPointMake(self.frame.width/3, 100), controlPoint2: CGPointMake(self.frame.width*2/3, -100))
        paths[0].addLineToPoint(CGPointMake(self.frame.width,-self.frame.height/2))
        paths[0].closePath()
        
        //create path for frame 2
        paths[1].moveToPoint(CGPointMake(0, -self.frame.height/2))
        paths[1].addLineToPoint(CGPointMake(0, 0))
        paths[1].addCurveToPoint(CGPointMake(self.frame.width, 0), controlPoint1: CGPointMake(self.frame.width/3, 100), controlPoint2: CGPointMake(self.frame.width*2/3, -100))
        paths[1].addLineToPoint(CGPointMake(self.frame.width,-self.frame.height/2))
        paths[1].closePath()
      
    }
    func generateNewRandomSlope()//updates paths array
    {
        
        paths.removeAtIndex(0)//removes path that is out of view
        paths.append(UIBezierPath())//adds new default bezier path to array
        
        let temp = CGFloat(arc4random() % 500)//next critical point
        
        //gives newly generated bezier path a randomly generated path
        paths[1].moveToPoint(CGPointMake(0, -self.frame.height/2))
        paths[1].addLineToPoint(CGPointMake(0, 0))
        paths[1].addCurveToPoint(CGPointMake(self.frame.width, 0), controlPoint1: CGPointMake(self.frame.width/3, lastCriticalPoint), controlPoint2: CGPointMake(self.frame.width*2/3, -temp))
        paths[1].addLineToPoint(CGPointMake(self.frame.width,-self.frame.height/2))
        paths[1].closePath()
        
        lastCriticalPoint = temp//update last critical point (used to make hills differentiable
    }
    func setupSun()
    {
        sun.xScale = 0.05//size
        sun.yScale = 0.05//size
        sun.position = CGPointMake(self.frame.width-sun.frame.width, self.frame.height/2-sun.frame.height)//positions sun top right with spacing
        addChild(sun)//add to scene
    }
    func setupSprite()
    {
        sprite.xScale = 0.03//size
        sprite.yScale = 0.03//size
        sprite.position = CGPointMake(self.frame.width/2,310)//starting position
        sprite.physicsBody=SKPhysicsBody(texture: self.view!.textureFromNode(sprite)!, size: sprite.size)//gives sprite the physics body of its png
        sprite.physicsBody?.allowsRotation=true//ball so rotation is required
        sprite.physicsBody?.affectedByGravity=true//clearly must be affected by gravity
        sprite.physicsBody?.dynamic=true//it moves so yea
        sprite.physicsBody?.categoryBitMask = PhysicsCat.sprite//sets reference to sprite
        sprite.physicsBody?.collisionBitMask = PhysicsCat.slope | PhysicsCat.sprite//sets to collide with slopes or (other sprites if there are any)
        sprite.physicsBody?.friction=0//dont want
        sprite.physicsBody?.linearDamping=0//any
        sprite.physicsBody?.angularDamping=0//of this
        sprite.physicsBody?.restitution=0.1//small amount of bouncy is $$$
        sprite.physicsBody?.contactTestBitMask = PhysicsCat.slope | PhysicsCat.sprite//sets to contact slopes (and sprites?)
        sprite.physicsBody?.velocity = CGVectorMake(0, 0)//start off with no velocity (Might change this?)
        self.addChild(sprite)//add sprite to game scene
    }
    func setupCamera()//to setup camera
    {
        camera = cam//does what you would expect
        cam.position = CGPointMake(sprite.position.x, cam.position.y)//moves camera so that sprite is in the center
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)//called whenever screen is touches
    {
        sprite.physicsBody?.applyImpulse(CGVectorMake(0, -30))//apply a downwards force on sprite
    }
    
    override func update(currentTime: CFTimeInterval)//called everytime a new frame is rendered
    {
       
        if((sprite.position.x-frame.width/2) > (slopes[0].position.x+frame.width))// if the first frame in slopes is not visible
        {
            slopes.removeAtIndex(0)//remove the first frame from slopes
            let tempSlope = SKShapeNode()//initialize new frame
            generateNewRandomSlope()//alter paths with new random path
            self.setupSlope(tempSlope, x: slopes[0].position.x+frame.width, newPath: paths[1])//add properties to new slope
            slopes.append(tempSlope)//add new slope to array
        }
        if(sprite.position.x > self.frame.width/2)//used to ensure we don't scroll behind first frame
        {
            cam.position = CGPointMake(sprite.position.x, cam.position.y)//move camera so that sprite is centered
            sun.position = CGPointMake(sprite.position.x+self.frame.width/2-sun.frame.width, sun.position.y)//move sun so it appears static
        }

    }
}
