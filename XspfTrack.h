//
//  XspfTrack.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "XspfComponent.h"


@interface XspfTrack : XspfComponent
{
	NSURL *location;
	NSString *title;
	
	QTMovie *movie;
	
	NSDate *savedDate;
}

- (void)setLocation:(NSURL *)location;
- (void)setLocationString:(NSString *)location;
- (NSURL *)location;
- (NSString *)locationString;

- (void)purgeQTMovie;

@end
