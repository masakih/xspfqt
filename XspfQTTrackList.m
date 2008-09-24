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
	if(self = [super init]) {
		[self setCurrentIndex:NSNotFound];
		
//		NSArray *elems = [element elementsForName:@"title"];
//		if(elems && [elems count] != 0) {
//			NSString *t = [[elems objectAtIndex:0] stringValue];
//			[self setTitle:t];
//		}
		
		NSArray *elems = [element elementsForName:@"track"];
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
	}
	
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
//	
//	id titleElem = [NSXMLElement elementWithName:@"title" stringValue:[self title]];
//	if(titleElem) {
//		[node addChild:titleElem];
//	}
	
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


- (void)setSelectionIndex:(NSUInteger)index
{
	[self setCurrentIndex:index];
}
- (void)setCurrentIndex:(unsigned)index
{
	if([tracks count] <= index && index != NSNotFound) return;
	
	if(index == currentIndex && index != NSNotFound) {
		id new = [tracks objectAtIndex:index];
		if(new == selectedComponent) {
			return;
		}
	}
	
	XspfQTComponent *newSelection = nil;
	if(index != NSNotFound) {
		newSelection = [tracks objectAtIndex:index];
	}
	if(selectedComponent != newSelection) {
		[selectedComponent removeObserver:self  forKeyPath:@"isPlayed"];
		[selectedComponent deselect];
		
		selectedComponent = newSelection;
		[selectedComponent addObserver:self
							forKeyPath:@"isPlayed"
							   options:NSKeyValueObservingOptionNew
							   context:NULL];
		[selectedComponent select];
	}
	
	[self willChangeValueForKey:@"isPlayed"];
	[self willChangeValueForKey:@"qtMovie"];
	[self willChangeValueForKey:@"currentTrack"];
	currentIndex = index;
	[self didChangeValueForKey:@"currentTrack"];
	[self didChangeValueForKey:@"qtMovie"];
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
- (void)insertChild:(XspfQTComponent *)child atIndex:(unsigned)index
{
	if(!child) return;
	if(![child isKindOfClass:[XspfQTComponent class]]) {
		NSLog(@"addChild: argument class is MUST kind of XspfQTComponent. "
			  @"but argument class is %@<%p>.",
			  NSStringFromClass([child class]), child);
		return;
	}
	
	[self willChangeValueForKey:@"children"];
	[tracks insertObject:child atIndex:index];
	[child setParent:self];
	[self didChangeValueForKey:@"children"];
	
	// 選択アイテムの前に挿入される場合は、currentIndexを変更する。
	if(index <= currentIndex) {
		[self setCurrentIndex:currentIndex + 1];
	}
}
// primitive.
- (void)removeChild:(XspfQTComponent *)child
{
	if(!child) return;
	if(![tracks containsObject:child]) return;
	
	NSUInteger index = [tracks indexOfObject:child];
	
	[self willChangeValueForKey:@"children"];
	[[child retain] autorelease];
	[child setParent:nil];
	[tracks removeObject:child];
	[self didChangeValueForKey:@"children"];
	
	// 再生位置の変更
	if(index <= currentIndex) {
		NSUInteger newIndex = currentIndex - 1;
		if(currentIndex == 0) {
			if([self childrenCount] == 0) {
				newIndex = NSNotFound;
			} else {
				newIndex = 0;
			}
		}
		[self setCurrentIndex:newIndex];
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
	return selectedComponent;
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
