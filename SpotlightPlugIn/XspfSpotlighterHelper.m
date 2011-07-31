//
//  XspfSpotlighterHelper.m
//  XspfSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import "XspfSpotlighterHelper.h"

#import "HMXSPFComponent.h"
#import "XspfQTValueTransformers.h"

#import <QTKit/QTKit.h>


@implementation XspfSpotlighterHelper

- (NSDictionary *)dataFromURL:(NSURL *)url
{
	id pool = [[NSAutoreleasePool alloc] init];
		
	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:url];
	if(!data) {
		NSLog(@"Can not load data from url.");
		goto fail;
	}
	
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithData:data
													options:0
													  error:&error] autorelease];
	if(!d) {
		NSLog(@"Can not init from data.");
		if(error) {
			NSLog(@"Error -> %@", error);
		}
		goto fail;
	}
	
	NSXMLElement *root = [d rootElement];
	id playlist = [HMXSPFComponent xspfComponentWithXMLElement:root];
	if(!playlist) {
		NSLog(@"Can not create HMXSPFComponent.");
		goto fail;
	}
	
	NSArray *tracks = [[playlist childAtIndex:0] children];
	CGFloat totalDuration = 0.0;
	NSUInteger movieNumber = 0;
	NSMutableArray *subtitles = [NSMutableArray array];
	for(HMXSPFComponent *track in tracks) {
		movieNumber++;
		
		NSString *subtitle = [track title];
		if(subtitle) {
			[subtitles addObject:subtitle];
		}
		
		NSDate *duration = [track duration];
		if(duration) {
			totalDuration += [duration timeIntervalSince1970] + [[NSTimeZone systemTimeZone] secondsFromGMT];
			continue;
		}
		
		NSURL *url = [track movieLocation];
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
							   (id)url, QTMovieURLAttribute,
							   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
							   nil];
		QTMovie *movie = [QTMovie movieWithAttributes:attrs error:nil];
		if(!movie) {
			NSLog(@"We can not create QTMovie.");
		}
//		NSLog(@"QTMovie load successful.");
		
		QTTime qtTime = [movie duration];
		id tr = [[[XspfQTTimeDateTransformer alloc] init] autorelease];
		duration =[tr transformedValue:[NSValue valueWithQTTime:qtTime]];
		totalDuration += [duration timeIntervalSince1970] + [[NSTimeZone systemTimeZone] secondsFromGMT];
	}
	
	
	NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:
							[NSNumber numberWithDouble:totalDuration], kMDItemDurationSeconds,
							[NSNumber numberWithUnsignedInteger:movieNumber], @"com_masakih_xspf_movieNumber",
							subtitles, @"com_masakih_xspf_subtitle",
							nil];
	
	[pool release];
	
	return [result autorelease];
	
fail:
	[pool release];
	return [NSDictionary dictionary];
}

@end
