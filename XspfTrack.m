//
//  XspfTrack.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfTrack.h"


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
	
	return self;
}
- (void)dealloc
{
	[location release];
	[title release];
	[movie release];
	[savedDate release];
	
	[super dealloc];
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

- (void)setTitle:(NSString *)t
{
	if(title == t) return;
	if([title isEqualToString:t]) return;
	
	[title autorelease];
	title = [t retain];
}
- (NSString *)title
{
	return title;
}
- (NSDate *)duration
{
	if(savedDate) return savedDate;
	
	if(!movie) return nil;
	
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	savedDate = [[t transformedValue:[NSValue valueWithQTTime:[movie duration]]] retain];
	return savedDate;
}
- (QTMovie *)qtMovie
{
	if(![QTMovie canInitWithURL:[self location]]) return nil;
	
	NSError *error = nil;
	
	movie = [[QTMovie alloc] initWithURL:[self location]
								   error:&error];
	
	[self willChangeValueForKey:@"duration"];
	[self didChangeValueForKey:@"duration"];
	
	return movie;
}
- (void)purgeQTMovie
{
	[movie release];
	movie = nil;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title:(%@)\nLocation:(%@)",
			[self title], [self location]];
}
@end
