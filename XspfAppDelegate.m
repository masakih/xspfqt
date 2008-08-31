//
//  XspfAppDelegate.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfAppDelegate.h"
#import "XspfValueTransformers.h"

@implementation XspfAppDelegate

+ (void)initialize
{
	[NSValueTransformer setValueTransformer:[[[XspfQTTimeTransformer alloc] init] autorelease]
									forName:@"XspfQTTimeTransformer"];
	[NSValueTransformer setValueTransformer:[[[XspfQTTimeDateTransformer alloc] init] autorelease]
									forName:@"XspfQTTimeDateTransformer"];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

@end
