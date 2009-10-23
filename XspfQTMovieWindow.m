//
//  XspfQTMovieWindow.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/02/24.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTMovieWindow.h"


@implementation XspfQTMovieWindow

static CGFloat titlebarHeight = 0;

+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		NSRect rect = {{0,0},{100,100}};
		NSRect frame = [self frameRectForContentRect:rect styleMask:NSTitledWindowMask];
		titlebarHeight = frame.size.height - rect.size.height;
	}
}
- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen
{
	if(!isChangingFullScreen) {
		return [super constrainFrameRect:frameRect toScreen:screen];
	}
	
	frameRect.origin.y += titlebarHeight;
		
	return frameRect;
}

- (void)setIsChangingFullScreen:(BOOL)flag
{
	isChangingFullScreen = flag;
}
- (CGFloat)titlebarHeight
{
	return titlebarHeight;
}
@end
