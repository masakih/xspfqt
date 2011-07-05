//
//  main.m
//  XspfSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfSpotlighterHelper.h"

int main(int argc, char *argv[])
{
	id pool = [[NSAutoreleasePool alloc] init];
	
	XspfSpotlighterHelper *server = [[XspfSpotlighterHelper alloc] init];
	
	NSConnection *con = [NSConnection serviceConnectionWithName:@"XspfQTSpotlightIndexer"
													 rootObject:server];
	if(!con) {
		NSLog(@"Can not create NSConnection instance.");
		exit(-1);
	}
	
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	NSDate *date = nil;
	while(YES) {
		id pool02 = [[NSAutoreleasePool alloc] init];
		date = [NSDate dateWithTimeIntervalSinceNow:10];
		[runloop runUntilDate:date];
		[pool02 release];
	}
	
	[pool release];
	return 0;
}
