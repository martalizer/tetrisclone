//
//  HelloWorldLayer.m
//  Tetris
//
//  Created by Martin Hedenberg on 2011-06-03.
//  Copyright Martalizer LTD inc AB under supervison of Setesh Entertainment Handelsbolag HB Stockholm Sweden 2011. 
//  Some rights reserved. This was a triumph.


// Import the interfaces
#import "Tetris.h"

// HelloWorldLayer implementation
@implementation Tetris

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Tetris *layer = [Tetris node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {

        // fullscreen stuff    
        CCDirectorMac *mac = (CCDirectorMac*) [CCDirector sharedDirector];
        [mac setFullScreen: ! [mac isFullScreen]]; 
                    
        // create and initialize a Sprite
        score = 0;
        // create and initialize a Label
        label = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:64];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /4 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
        
        NSString *scoreString = [NSString stringWithFormat:@"%D", score];
        
        [label setString:scoreString];
        [label retain];
        
        tetrisTexture = [[CCTextureCache sharedTextureCache] addImage: @"Tetris.png"];   
        myBlockTexture = [[CCTextureCache sharedTextureCache] addImage: @"Block.png"];
        yellowBlock = [[CCTextureCache sharedTextureCache] addImage: @"BlockYellow.png"];
        mySprite = [CCSprite spriteWithTexture:tetrisTexture];
        
        float tileSize = size.height/22;
        float tileScale = tileSize/256;
        level = 1;
        n = 0;
        backgroundOpacity = 40;
        collisionCurrentBlock = false;
        xPos = 3;
        newblock = FALSE;
        srand((unsigned)time(NULL));
        [self clear];
        mySprite.scale = size.height/500;
        block = rand() % 6;
        
        [self makeFixAtBlocks];
        
        self.isKeyboardEnabled = YES;
        
        CGPoint leftTopPos = ccp(size.width/2 - (tileSize*5), size.height-(tileSize/2)); 
        
        //  Create the blockField and fill with sprites representing the tiles that build the blocks.
        for (int y=0;y<23;y++) {
            for (int x=0;x<10;x++) {
                blockField[x][y] = [CCSprite spriteWithTexture:myBlockTexture];
                blockField[x][y].scale = tileScale;
                blockField[x][y].position = ccp(leftTopPos.x+tileSize*x,leftTopPos.y-tileSize*y);
                [self addChild: blockField[x][y]];
                blockField[x][y].visible = TRUE;
                blockField[x][y].opacity = backgroundOpacity;
            }
        }
                
		// position the sprite on the center of the screen
        mySprite.position =  ccp( size.width /2 , size.height/2 );
        mySprite.opacity = 0; //100 will enable, 0 will disable
        // initialize various variables
        startPosY = mySprite.position.y;
        startPosX = mySprite.position.x;
        xSpeed = 0.5;
        ySpeed = 1;
        speed = size.width /100;

        // add the some shit as a child to this Layer
		[self addChild: mySprite];
        [self schedule:@selector(update) interval:1.0/200];
        [self schedule:@selector(updateBlock) interval:0.4*level];
        
        // copy to current block matrix  
        for(int x = 0; x<4; x++)
            for (int y = 0; y<4; y++)
                blockActive[x][y] = blockPile[block][x][y];  
	}
	return self;
}

-(void) clear
{
    for (int y=0;y<22;y++) {
        for (int x=0;x<10;x++) {
            blockField[x][y].opacity = backgroundOpacity;
        }
    }
    level = 1;
    GAMEOVER = FALSE;
    score = 0;
    [self newBlock];
    [self drawBlock];
}

-(void) updateBlock
{ 
    if (!GAMEOVER) {
        mySprite.visible = TRUE;
        
        if (!newblock) {
            [self removeBlock];
            n++;
        }
        else {
            [self lineCheck];
            [self newBlock];
        } 
                
        NSString *scoreString = [NSString stringWithFormat:@"%D", score];
        [label setString:scoreString];        
        [self fallCollisionTest]; //this will set newblock = TRUE if it detects collision               
    } 
    else //if GAMEOVER
        mySprite.visible = FALSE;
}

-(void) makeFixAtBlocks //initialize the various blocks. (int blockPile[7][4][4];)
                    
                        //   0   1   2   3   4    5   6    
                        //   X                             
                        //   X   XX   X  XX   XX  XX   XX  
                        //   X   XX  XXX  XX XX    X   X   
                        //   X                     X   X   
{
    // Write zeroes everywhere.
    for (int row = 0; row<7; row++) 
        for (int xpos = 0; xpos<4; xpos++) 
            for (int ypos = 0; ypos<4; ypos++)
                blockPile[row][xpos][ypos] = 0;

    // Fill with useful data.
    
    blockPile[0][2][0]=1;
    blockPile[0][2][1]=1;
    blockPile[0][2][2]=1;
    blockPile[0][2][3]=1;
        
    blockPile[1][1][1]=1;
    blockPile[1][1][2]=1;
    blockPile[1][2][1]=1;
    blockPile[1][2][2]=1;
       
    blockPile[2][1][1]=1;
    blockPile[2][0][2]=1;
    blockPile[2][1][2]=1;
    blockPile[2][2][2]=1;

    blockPile[3][1][1]=1;
    blockPile[3][2][1]=1;
    blockPile[3][2][2]=1;
    blockPile[3][3][2]=1;
    
    blockPile[4][3][1]=1;
    blockPile[4][2][1]=1;
    blockPile[4][2][2]=1;
    blockPile[4][1][2]=1;
    
    blockPile[5][1][1]=1;
    blockPile[5][2][1]=1;
    blockPile[5][2][2]=1;
    blockPile[5][2][3]=1;
    
    blockPile[6][2][1]=1;
    blockPile[6][1][1]=1;
    blockPile[6][1][2]=1;
    blockPile[6][1][3]=1;
}

-(void) rotate
{
    int rotateCollision = FALSE;
    
    //Rotate copy to blockTemp;
    for(int x = 0; x<4; x++) {
        int z = 3;
        for (int y = 0; y<4; y++) {
            blockTemp[x][y] = blockActive[z][x];
            z--;
        }
    }
    
    //check if blockTemp collides with other blocks or walls
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++)
            if (blockTemp[x][y] > 0)
                if(x+xPos < 10 && x+xPos > -1)
                    {
                        if (blockField[x+xPos][y+n].opacity == 255)
                            rotateCollision = TRUE;
                    }
                    else {rotateCollision = TRUE;}
                
    // if no collision update the active block with the rotated block
    if(rotateCollision == FALSE)
        for(int x = 0; x<4; x++)
            for (int y = 0; y<4; y++)
                blockActive[x][y] = blockTemp[x][y];
}

-(void) removeBlock
{
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++)
            if (blockActive[x][y] > 0) blockField[x+xPos][y+n].opacity = backgroundOpacity;
}

-(void) drawBlock
{
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++) 
            if (blockActive[x][y] > 0) blockField[x+xPos][y+n].opacity = 255;
}

-(void) moveCollisionCheck
{
    moveCollision = FALSE;
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++)    
            if (blockActive[x][y] > 0)
                if(newxPos >=0 && newxPos < 10)
                    if (blockField[x+newxPos][y+n].opacity == 255)
                        moveCollision = TRUE; 
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++)
            if (blockActive[x][y] > 0)
                if (x+newxPos > 9 | x+newxPos < 0)
                    moveCollision = TRUE;
    if(moveCollision == FALSE)
        xPos = newxPos;
}

-(void) instantFall
{
    while(!collisionCurrentBlock)
        [self updateBlock];
}

-(void) update
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    mySprite.position = ccp(mySprite.position.x, startPosY+((sinf(sinSpeed))*size.height/5));    
    sinSpeed=sinSpeed+0.1;
    if(xSpeed > 0) xSpeed = speed;
    else xSpeed = -speed;    
    if(ySpeed >0) ySpeed = speed;
    else ySpeed = -speed;    
    if (mySprite.position.x >= size.width-(128*mySprite.scale)) xSpeed = -speed;
    if (mySprite.position.x <= 128*mySprite.scale) xSpeed = speed;
    if (mySprite.position.y >= size.height-(128*mySprite.scale)) ySpeed = -speed;
    if (mySprite.position.y <= 128*mySprite.scale) ySpeed = speed;
    mySprite.position = ccp(mySprite.position.x+xSpeed,mySprite.position.y);
}

-(void)fallCollisionTest
{
    collisionCurrentBlock = FALSE;

    // Damn, this code looks happy.
    
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++) 
            if (blockActive[x][y] > 0)
                if (x+xPos > -1 & x+xPos < 10)
                    if (blockField[x+xPos][y+n].opacity == 255 | y+n == 22)
                        collisionCurrentBlock = TRUE;

    if (collisionCurrentBlock) {
        if(n <= 1)
            GAMEOVER = TRUE;
        n--;
        newblock = TRUE;
    }
    [self drawBlock];
}

-(void) newBlock
{
    n=-1;        
    block = rand() % 6;
    xPos = 3;

    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++)
            blockActive[x][y] = blockPile[block][x][y];
    newblock = FALSE;
    
    for(int x = 0; x<4; x++)
        for (int y = 0; y<4; y++) 
            if (blockActive[x][y] > 0)
                if (x+xPos > -1 & x+xPos < 10)
                    if (y+n < 0)
                        n++;
}

-(void) lineCheck
{
    for (int y=0;y<23;y++) {
        int rowcounter = 0;
        for (int x=0;x<10;x++) {
            if (blockField[x][y].opacity == 255)
                rowcounter++;
            if (rowcounter == 10) {
                score += 100;
                for(int line = y; line>0; line--) {
                    for(int rowPos=0;rowPos<10;rowPos++) {
                        blockField[rowPos][line].opacity = blockField[rowPos][line-1].opacity;
                    }
                }      
            }
        }
    }
}

// start keystuff
- (BOOL)ccKeyDown:(NSEvent*)keyDownEvent
{
    int keyCode = [keyDownEvent keyCode];
    // NSLog([keyDownEvent description]); 
    
    if(!GAMEOVER)
    {
        // Set pressed key to true
        if (keyCode == 13) {     // up
            if (!collisionCurrentBlock) {
                [self removeBlock];
                [self rotate];
                [self drawBlock];
            }
        }
        
        if (keyCode == 1) [self updateBlock]; // Down
        
        if (keyCode == 2) {     // left
            if (!collisionCurrentBlock) {
                newxPos = xPos+1;
                [self removeBlock];
                [self moveCollisionCheck]; //check if blocks are blocking the new position sideways
                [self drawBlock];
            }
        } 
        
        if (keyCode ==  0) {    // right
            if (!collisionCurrentBlock) { // do NOT try to move if the block is considered collided
                newxPos = xPos-1;
                [self removeBlock];
                [self moveCollisionCheck]; //check if blocks are blocking the new position sideways
                [self drawBlock];
            }
        }
        if (keyCode == 49) [self instantFall]; // Space
    }
	// Other keys
	if (keyCode == 53) { [self clear]; } // Escape
    return TRUE;
}

- (BOOL)ccKeyUp:(NSEvent*)keyUpEvent
{
	// Get pressed key (code)
	NSString * character = [keyUpEvent characters];
    unichar keyCode = [character characterAtIndex: 0];
    
	// Set unpressed key to false
	if (keyCode == 119) { playerMovement[1] = FALSE; } // Up
	if (keyCode == 115) { playerMovement[2] = FALSE; } // Down
	if (keyCode == 100) { playerMovement[3] = FALSE; } // Left
	if (keyCode ==  97) { playerMovement[4] = FALSE; } // Right
    return TRUE;
}

// slut keystuff

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end










