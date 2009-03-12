//
//  XspfQTTrack.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTTrack.h"

@interface XspfQTTrack (Private)
- (void)setSavedDateWithQTTime:(QTTime)qttime;
//- (NSDate *)duration;
@end

@implementation XspfQTTrack
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:@"location"];
	if(!elems || [elems count] == 0) {
		[self release];
		return nil;
	}
	
	NSString *loc = [[elems objectAtIndex:0] stringValue];
	[self setLocationString:loc];
	
	NSString *t;
	elems = [element elementsForName:@"title"];
	if(!elems || [elems count] == 0) {
		t = [[self locationString] lastPathComponent];
		t = [t stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
	[self setDuration:nil];
	
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
	NSString *str = [[self location] absoluteString];
	
	return [str stringByReplacingOccurrencesOfString:@"//localhost/"
										  withString:@"///"];
}

- (void)setSavedDateWithQTTime:(QTTime)qttime
{
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	duration = [[t transformedValue:[NSValue valueWithQTTime:qttime]] retain];
}
- (NSDate *)savedDate
{
	return duration;
}
- (void)setDuration:(NSDate *)newDuration
{
	[duration autorelease];
	duration = [newDuration retain];
}
- (NSDate *)duration
{
	if(duration) return duration;
	
	return nil;
}
- (NSURL *)movieLocation
{
	return location;
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

- (BOOL)isEqual:(id)other
{
	if(![super isEqual:other]) return NO;
	if(![[self locationString] isEqual:[other locationString]]) return NO;
	
	return YES;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title:(%@)\nLocation:(%@)",
			[self title], [self location]];
}
@end
