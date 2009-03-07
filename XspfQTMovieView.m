//
//  XspfQTMovieView.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/07.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTMovieView.h"


@implementation XspfQTMovieView

- (void)keyDown:(NSEvent *)event
{
#define kPeriodKeyCode	47
#define kRightKeyCode	123
#define kLeftKeyCode	124
#define kDownKeyCode	125
#define kUpKeyCode		126
	//
	switch([event keyCode]) {
		case kPeriodKeyCode:
		case kRightKeyCode:
		case kLeftKeyCode:
		case kDownKeyCode:
		case kUpKeyCode:
			return;
	}
	
	NSLog(@"KeyCode -> %d", [event keyCode]);
	
	[super keyDown:event];
}
@end
