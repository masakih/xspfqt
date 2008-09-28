//
//  XspfQTPlaylist.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/28.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTPlaylist.h"


@implementation XspfQTPlaylist
- (id)initWithXMLElement:(NSXMLElement *)element
{
	if(self = [super init]) {
		[self setSelectionIndex:NSNotFound];
		
		NSArray *elems = [element elementsForName:@"trackList"];
		if(!elems) {
			[self release];
			return nil;
		}
		
		trackLists = [[NSMutableArray alloc] init];
		
		for(NSXMLElement *trackListsElem in elems) {
			XspfQTComponent *trackList = [XspfQTComponent xspfComponemtWithXMLElement:trackListsElem];
			if(trackList) {
				[self addChild:trackList];
			}
		}
		
		NSString *t;
		elems = [element elementsForName:@"title"];
		if(elems && [elems count] != 0) {
			t = [[elems objectAtIndex:0] stringValue];
			[self setTitle:t];
		}
	}
	
	return self;
}
- (void)dealloc
{
	[self setSelectionIndex:NSNotFound];
	
	[trackLists release];
	
	[super dealloc];
}
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:@"playlist"];
	[node addAttribute:[NSXMLNode attributeWithName:@"version"
										stringValue:@"1"]];
	[node addAttribute:[NSXMLNode attributeWithName:@"xmlns"
										stringValue:@"http://xspf.org/ns/0/"]];
	
	if([self title]) {
		id t = [NSXMLElement elementWithName:@"title"
								 stringValue:[self title]];
		[node addChild:t];
	}
	
	for(id n in trackLists) {
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

- (void)setSelectionIndex:(unsigned)index
{
	if([trackLists count] <= index && index != NSNotFound) return;
	
	if(index == selectionIndex && index != NSNotFound) {
		id new = [trackLists objectAtIndex:index];
		if(new == selectedComponent) {
			return;
		}
	}
	
	XspfQTComponent *newSelection = nil;
	if(index != NSNotFound) {
		newSelection = [trackLists objectAtIndex:index];
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
	selectionIndex = index;
	[self didChangeValueForKey:@"currentTrack"];
	[self didChangeValueForKey:@"qtMovie"];
	[self didChangeValueForKey:@"isPlayed"];
}
- (unsigned)selectionIndex
{
	return selectionIndex;
}

- (void)next
{
	[self setSelectionIndex:[self selectionIndex] + 1];
}
- (void)previous
{
	[self setSelectionIndex:[self selectionIndex] - 1];
}
- (NSArray *)children
{
	return trackLists;
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
	[trackLists insertObject:child atIndex:index];
	[child setParent:self];
	[self didChangeValueForKey:@"children"];
	
	// 選択アイテムの前に挿入される場合は、selectionIndexを変更する。
	if(index <= selectionIndex) {
		[self setSelectionIndex:selectionIndex + 1];
	}
}
// primitive.
- (void)removeChild:(XspfQTComponent *)child
{
	if(!child) return;
	if(![trackLists containsObject:child]) return;
	
	NSUInteger index = [trackLists indexOfObject:child];
	
	[self willChangeValueForKey:@"children"];
	[[child retain] autorelease];
	[child setParent:nil];
	[trackLists removeObject:child];
	[self didChangeValueForKey:@"children"];
	
	// 再生位置の変更
	if(index <= selectionIndex) {
		NSUInteger newIndex = selectionIndex - 1;
		if(selectionIndex == 0) {
			if([self childrenCount] == 0) {
				newIndex = NSNotFound;
			} else {
				newIndex = 0;
			}
		}
		[self setSelectionIndex:newIndex];
	}
}

- (void)addChild:(XspfQTComponent *)child
{
	unsigned num = [trackLists count];
	[self insertChild:child atIndex:num];
}
- (void)removeChildAtIndex:(unsigned)index
{
	id child = [trackLists objectAtIndex:index];
	[self removeChild:child];
}

- (NSString *)description
{
	return [trackLists description];
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
