//
//  XspfQTMovieWindow.h
//  XspfQT
//
//  Created by Hori,Masaki on 09/02/24.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfQTMovieWindow : NSWindow
{
	BOOL isChangingFullScreen;
}

- (void)setIsChangingFullScreen:(BOOL)flag;
- (CGFloat)titlebarHeight;

@end
