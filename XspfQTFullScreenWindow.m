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
	if(_delegate && [_delegate respondsToSelector:_cmd]) {
		[_delegate cancelOperation:sender];
	}
	
	[super cancelOperation:sender];
}
@end
