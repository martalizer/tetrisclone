//
//  AppDelegate.h
//  Tetris
//
//  Created by Martin Hedenberg on 2011-06-03.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

@interface TetrisAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
