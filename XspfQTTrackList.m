//
//  XspfQTTrackList.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTTrackList.h"


@implementation XspfQTTrackList
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:@"title"];
	if(elems && [elems count] != 0) {
		NSString *t = [[elems objectAtIndex:0] stringValue];
		[self setTitle:t];
	}
	
	elems = [element elementsForName:@"track"];
	if(!elems) {
		[self release];
		return nil;
	}
	tracks = [[NSMutableArray alloc] init];
	
	unsigned i, count;
	for(i = 0, count = [elems count]; i < count; i++) {
		NSXMLElement *trackElem = [elems objectAtIndex:i];
		XspfQTComponent *track = [XspfQTComponent xspfComponemtWithXMLElement:trackElem];
		if(track) {
			[self addChild:track];
		}
	}
	[self setCurrentIndex:NSNotFound];
	
	return self;
}
- (void)dealloc
{
	[self setCurrentIndex:NSNotFound];
	
	[tracks release];
	
	[super dealloc];
}
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:@"trackList"];
	
	id titleElem = [NSXMLElement elementWithName:@"title" stringValue:[self title]];
	if(titleElem) {
		[node addChild:titleElem];
	}
	
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
	if([keyPath isEqualToString:@"isPlayed"]) {
//		NSLog(@"Observe key path(%@).", keyPath);
		[self willChangeValueForKey:@"isPlayed"];
		[self didChangeValueForKey:@"isPlayed"];
		return;
	}
	
	[super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];
}

// this mothod not check toTrack and fromTrack are in tracks array.
// Do not call directly.
- (void)changeObserveFrom:(XspfQTComponent *)fromTrack to:(XspfQTComponent *)toTrack
{
	if(fromTrack == toTrack) return;
	
	@try {
		[toTrack addObserver:self
				  forKeyPath:@"isPlayed"
					 options:NSKeyValueObservingOptionNew
					 context:NULL];
		[fromTrack removeObserver:self forKeyPath:@"isPlayed"];
	}
	@catch (id ex) {
//		NSLog(@"Caught exception(%@).",ex);
		if(![[ex name] isEqualToString:NSRangeException]) {
			NSLog(@"Exception ### named %@", [ex name]);
			@throw;
		}
	}
	@finally {
//		NSLog(@"Prev -> %@\nNew -> %@", fromTrack, toTrack);
		[self willChangeValueForKey:@"isPlayed"];
		[fromTrack deselect];
		[toTrack select];
		[self didChangeValueForKey:@"isPlayed"];
	}
}	

- (void)setSelectionIndex:(unsigned)index
{
	[self setCurrentIndex:index];
}
- (void)setCurrentIndex:(unsigned)index
{
	unsigned prev;
	
	if(index < 0) return;
	if([tracks count] <= index && index != NSNotFound) return;
	
	[self willChangeValueForKey:@"qtMovie"];
	[self willChangeValueForKey:@"currentTrack"];
	prev = currentIndex;
	currentIndex = index;
	[self didChangeValueForKey:@"currentTrack"];
	[self didChangeValueForKey:@"qtMovie"];
	
	XspfQTComponent *t= nil;
	@try {
		t = [tracks objectAtIndex:prev];
	}
	@catch (id ex) {
		if(![[ex name] isEqualToString:NSRangeException]) {
			NSLog(@"Exception ### named %@", [ex name]);
			@throw;
		}
	}
	XspfQTComponent *t2 = [self currentTrack];
	
	[self changeObserveFrom:t to:t2];
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
- (void)insertChild:(XspfQTComponent *)child atIndex:(unsigned)index
{
	if(!child) return;
	if(![child isKindOfClass:[XspfQTComponent class]]) {
		NSLog(@"addChild: argument class is MUST kind of XspfQTComponent. "
			  @"but argument class is %@<%p>.",
			  NSStringFromClass([child class]), child);
		return;
	}
	[tracks insertObject:child atIndex:index];
	[child setParent:self];
}
// primitive.
- (void)removeChild:(XspfQTComponent *)child
{
	if(!child) return;
	if(![tracks containsObject:child]) return;
	
	NSUInteger index = [tracks indexOfObject:child];
	BOOL isSelectedItem = [child isSelected];
	BOOL mustChangeSelection = NO;
		
	if(index <= currentIndex) {
		mustChangeSelection = YES;
	}
	
	[self willChangeValueForKey:@"children"];
	[[child retain] autorelease];
	[child setParent:nil];
	[tracks removeObject:child];
	[self didChangeValueForKey:@"children"];
	
	if(mustChangeSelection) {
		// ### CAUTION ###
		// this line directly change currentIndex.
		[self willChangeValueForKey:@"qtMovie"];
		[self willChangeValueForKey:@"currentTrack"];
		currentIndex--;
		[self didChangeValueForKey:@"currentTrack"];
		[self didChangeValueForKey:@"qtMovie"];
		
		id newSelection = nil;
		id oldSelection = nil;
		if(isSelectedItem) {
			oldSelection = child;
			newSelection = [self currentTrack];
		}
		[self changeObserveFrom:oldSelection to:newSelection];
	}
}

- (void)addChild:(XspfQTComponent *)child
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

- (XspfQTComponent *)currentTrack
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
	XspfQTComponent *t = [self currentTrack];
	if(t) {
		return [t isPlayed];
	}
	return NO;
}
@end
