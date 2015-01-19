//
//  HelloWorldLayer.h
//  Tetris
//
//  Created by Martin Hedenberg on 2011-06-03.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface Tetris : CCLayer
{
    CCSprite *mySprite;
    CCSprite *mySprite2;
    CCTexture2D *myBlockTexture;
    CCTexture2D *yellowBlock;
    CCTexture2D *tetrisTexture;
    CCSprite *blockField[11][24];
    int tempBlockField;
    CCSprite *nextBlockField[4][4];
    int blockPile[7][4][4];
    int nextBlock[4][4];
    int blockActive[4][4];
    int blockTemp[4][4];
    float xSpeed,ySpeed, xSpeed2;
    float speed,sinSpeed;
    float startPosX,startPosY;
    int level, n, block, collisionCurrentBlock, GAMEOVER, PROTECTED, xPos, newxPos, hover;
    int playerMovement[5];
    int moveCollision;
    int newblock;
    int score;
    CCLabelTTF *label;
    int backgroundOpacity;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void) makeFixAtBlocks;
-(void) removeBlock;
-(void) fallCollisionTest;
-(void) drawBlock;
-(void) instantFall;
-(void) clear;
-(void) newBlock;
-(void) lineCheck;
@end
