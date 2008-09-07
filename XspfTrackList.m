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
			[self addChild:track];
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
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:@"trackList"];
	
	NSEnumerator *tracksEnum = [tracks objectEnumerator];
	id n;
	while(n = [tracksEnum nextObject]) {
		[node addChild:[n XMLElement]];
	}
	
	return node;
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
- (void)setSelectionIndex:(unsigned)index
{
	[self setCurrentIndex:index];
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

- (void)next
{
	[self setCurrentIndex:[self currentIndex] + 1];
}
- (void)previous
{
	[self setCurrentIndex:[self currentIndex] - 1];
}
- (NSArray *)children
{
	return tracks;
}
- (BOOL)isLeaf
{
	return NO;
}

// primitive.
- (void)insertChild:(XspfComponent *)child atIndex:(unsigned)index
{
	if(!child) return;
	if(![child isKindOfClass:[XspfComponent class]]) {
		NSLog(@"addChild: argument class is MUST kind of XspfComponent. "
			  @"but argument class is %@<%p>.",
			  NSStringFromClass([child class]), child);
		return;
	}
	[tracks insertObject:child atIndex:index];
	[child setParent:self];
}
// primitive.
- (void)removeChild:(XspfComponent *)child
{
	if(!child) return;
	if(![tracks containsObject:child]) return;
	
	[child setParent:nil];
	[tracks removeObject:child];
}

- (void)addChild:(XspfComponent *)child
{
	unsigned num = [tracks count];
	[self insertChild:child atIndex:num];
}
- (void)removeChildAtIndex:(unsigned)index
{
	id child = [tracks objectAtIndex:index];
	[self removeChild:child];
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
