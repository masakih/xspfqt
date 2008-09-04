//
//  XspfTrackList.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfTrackList.h"
#import "XspfTrack.h"


@implementation XspfTrackList
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:@"track"];
	if(!elems) {
		[self release];
		return nil;
	}
	
	tracks = [[NSMutableArray alloc] init];
	
	unsigned i, count;
	for(i = 0, count = [elems count]; i < count; i++) {
		NSXMLElement *trackElem = [elems objectAtIndex:i];
		XspfTrack *track = [XspfTrack xspfComponemtWithXMLElement:trackElem];
		if(track) {
			[tracks addObject:track];
		}
	}
	[self setCurrentIndex:0];
	
	return self;
}
- (void)dealloc
{
	[[self currentTrack] removeObserver:self forKeyPath:@"isPlayed"];
	
	[tracks release];
	[title release];
	
	[super dealloc];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqual:@"isPlayed"]) {
		[self willChangeValueForKey:@"isPlayed"];
		[self didChangeValueForKey:@"isPlayed"];
		return;
	}
	
	[super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];
}
- (void)setCurrentIndex:(unsigned)index
{
	unsigned prev;
	
	if(index < 0) return;
	if([tracks count] <= index) return;
	
	[self willChangeValueForKey:@"qtMovie"];
	[self willChangeValueForKey:@"currentTrack"];
	prev = currentIndex;
	currentIndex = index;
	[self didChangeValueForKey:@"qtMovie"];
	[self didChangeValueForKey:@"currentTrack"];
	
	[self willChangeValueForKey:@"isPlayed"];
	XspfTrack *t= nil;
	@try {
		t = [tracks objectAtIndex:prev];
		[t removeObserver:self forKeyPath:@"isPlayed"];
	}
	@catch (id ex) {
		if(![[ex name] isEqualTo:NSRangeException]) {
			NSLog(@"Exception ### named %@", [ex name]);
			@throw;
		}
	}
	
	if(t) {
		[t purgeQTMovie];
		[t deselect];
	}
	
	XspfComponent *t2 = [self currentTrack];
	[t2 select];
	[t2 addObserver:self
		 forKeyPath:@"isPlayed"
			options:NSKeyValueObservingOptionNew
			context:NULL];
	[self didChangeValueForKey:@"isPlayed"];

}
- (unsigned)currentIndex
{
	return currentIndex;
}
- (NSArray *)children
{
	return tracks;
}

- (void)next
{
	[self setCurrentIndex:[self currentIndex] + 1];
}
- (void)previous
{
	[self setCurrentIndex:[self currentIndex] - 1];
}
- (NSString *)description
{
	return [tracks description];
}

- (XspfComponent *)currentTrack
{
	if([tracks count] > currentIndex) {
		return [tracks objectAtIndex:currentIndex];
	}
	return nil;
}

- (QTMovie *)qtMovie
{
	return [[self currentTrack] qtMovie];
}

- (void)setTitle:(NSString *)t
{
	if(title == t) return;
	[title autorelease];
	title = [t copy];
}
- (NSString *)title
{
	return title;
}
- (void)setIsPlayed:(BOOL)state {}
- (BOOL)isPlayed
{
	XspfComponent *t = [self currentTrack];
	if(t) {
		return [t isPlayed];
	}
	return NO;
}
@end
