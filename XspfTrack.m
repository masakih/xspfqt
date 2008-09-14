//
//  XspfTrack.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfTrack.h"

@interface XspfTrack (Private)
- (void)setSavedDateWithQTTime:(QTTime)qttime;
- (NSDate *)duration;
@end

@implementation XspfTrack
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:@"location"];
	if(!elems || [elems count] == 0) {
		[self release];
		return nil;
	}
	
	NSString *loc = [[elems objectAtIndex:0] stringValue];;
	[self setLocationString:loc];
	
	NSString *t;
	elems = [element elementsForName:@"title"];
	if(!elems || [elems count] == 0) {
		t = [[self locationString] lastPathComponent];
	} else {
		t = [[elems objectAtIndex:0] stringValue];
	}
	[self setTitle:t];
	
	elems = [element elementsForName:@"duration"];
	if(elems && [elems count] != 0) {
		t = [[elems objectAtIndex:0] stringValue];
		NSTimeInterval ti = [t doubleValue] / 1000;
		QTTime q = QTMakeTimeWithTimeInterval(ti);
		[self setSavedDateWithQTTime:q];
	}
	
	return self;
}
- (void)dealloc
{
	[location release];
	[movie release];
	[savedDate release];
	
	[super dealloc];
}
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:@"track"];
	
	id locElem = [NSXMLElement elementWithName:@"location" stringValue:[self locationString]];
	if(locElem) {
		[node addChild:locElem];
	}
	id titleElem = [NSXMLElement elementWithName:@"title" stringValue:[self title]];
	if(titleElem) {
		[node addChild:titleElem];
	}
	
	id d = [self duration];
	if(d) {
		NSTimeInterval t = [d timeIntervalSince1970];
		t += [[NSTimeZone systemTimeZone] secondsFromGMT];
		unsigned long long scaledT = (unsigned long long)t;
		scaledT *= 1000;
		id durationElem = [NSXMLElement elementWithName:@"duration"
											stringValue:[NSString stringWithFormat:@"%qu", scaledT]];
		if(durationElem) {
			[node addChild:durationElem];
		}
	}
	
	return node;
}
- (void)setLocation:(NSURL *)loc
{
	if(location && ![location isKindOfClass:[NSURL class]]) return;
	if(location == loc) return;
	if([location isEqualTo:loc]) return;
	
	[location autorelease];
	location = [loc retain];
}
- (NSURL *)location
{
	return location;
}
- (void)setLocationString:(NSString *)loc
{
	[self setLocation:[NSURL URLWithString:loc]];
}
- (NSString *)locationString
{
	return [[self location] absoluteString];
}

- (void)setSavedDateWithQTTime:(QTTime)qttime
{
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	savedDate = [[t transformedValue:[NSValue valueWithQTTime:qttime]] retain];
}
- (NSDate *)savedDate
{
	return savedDate;
}
- (NSDate *)duration
{
	if(savedDate) return savedDate;
	
	if(!movie) return nil;
	
	[self setSavedDateWithQTTime:[movie duration]];
	return [self savedDate];
}
- (QTMovie *)qtMovie
{
	if(movie) {
		[[self class] cancelPreviousPerformRequestsWithTarget:self];
		return movie;
	}
	if(![QTMovie canInitWithURL:[self location]]) return nil;
	
	NSError *error = nil;
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self location], QTMovieURLAttribute,
						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
						   nil];
	movie = [[QTMovie alloc] initWithAttributes:attrs error:&error];
//	movie = [[QTMovie alloc] initWithURL:[self location] error:&error];
	
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//		[nc addObserver:self
//			   selector:@selector(notifee:)
//				   name:@"QTMoviePrerollCompleteNotification"
//				 object:movie];
		[nc addObserver:self
			   selector:@selector(notifee:)
				   name:QTMovieRateDidChangeNotification
				 object:movie];
//		[nc addObserver:self
//			   selector:@selector(notifee:)
//				   name:@"QTMovieDidEndNotification"
//				 object:movie];
	}
	
	
	[self willChangeValueForKey:@"duration"];
	[self didChangeValueForKey:@"duration"];
	
	return movie;
}
- (void)setIsPlayed:(BOOL)state
{
	isPlayed = state;
}
- (BOOL)isPlayed
{
	return isPlayed;
}
- (void)next
{
	[[self parent] next];
}
- (void)previous
{
	[[self parent] previous];
}

- (void)deselect
{
	[movie stop];
	[self performSelector:@selector(purgeQTMovie)
			   withObject:nil
			   afterDelay:4.5];
	[self setIsPlayed:NO];
	[super deselect];
}
- (void)purgeQTMovie
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self
				  name:nil
				object:movie];
	
//	[movie invalidate];
	NSLog(@"Purge! retain count is %u", [movie retainCount]);
	
	[movie release];
	movie = nil;
}

- (void)notifee:(id)notification
{
//	NSLog(@"Notifed: name -> (%@)\ndict -> (%@)", [notification name], [notification userInfo]);
	
	NSNumber *rateValue = [[notification userInfo] objectForKey:QTMovieRateDidChangeNotificationParameter];
	if(rateValue) {
		float rate = [rateValue floatValue];
		if(rate == 0) {
			[self setIsPlayed:NO];
		} else if(rate == 1) {
			[self setIsPlayed:YES];
		}
	}
}

- (NSUInteger)hash
{
	return [location hash];
}
- (BOOL)isEqual:(XspfTrack *)other
{
	if(![other isMemberOfClass:[XspfTrack class]]) return NO;
	if(![[other location] isEqual:location]) return NO;
	if(![[other title] isEqualToString:[self title]]) return NO;
	
	return YES;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title:(%@)\nLocation:(%@)",
			[self title], [self location]];
}
@end
