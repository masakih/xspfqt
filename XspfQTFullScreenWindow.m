//
//  XspfQTFullScreenWindow.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTFullScreenWindow.h"


@implementation XspfQTFullScreenWindow
- (BOOL)canBecomeKeyWindow
{
	return YES;
}
- (void)cancelOperation:(id)sender
{
	id d = [self delegate];
	if(d && [d respondsToSelector:_cmd]) {
		[d performSelector:_cmd withObject:sender];
	}
	
	[super cancelOperation:sender];
}
@end
