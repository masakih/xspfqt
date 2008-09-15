//
//  XspfQTTrack.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "XspfQTComponent.h"


@interface XspfQTTrack : XspfQTComponent
{
	NSURL *location;
	
	QTMovie *movie;
	
	NSDate *savedDate;
	
	BOOL isPlayed;
}

- (void)setLocation:(NSURL *)location;
- (void)setLocationString:(NSString *)location;
- (NSURL *)location;
- (NSString *)locationString;

- (void)purgeQTMovie;

@end
