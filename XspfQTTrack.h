//
//  XspfQTTrack.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XspfQTComponent.h"


@interface XspfQTTrack : XspfQTComponent
{
	NSURL *location;
	NSDate *duration;
	BOOL isPlayed;
}

- (void)setLocation:(NSURL *)location;
- (void)setLocationString:(NSString *)location;
- (NSURL *)location;
- (NSString *)locationString;
@end
