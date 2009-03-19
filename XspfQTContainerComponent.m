//
//  XspfQTContainerComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/28.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTContainerComponent.h"

@interface XspfQTContainerComponent(XspfQTPrivate)
- (void)setCurrentTrack:(XspfQTComponent *)track;
@end

@implementation XspfQTContainerComponent
- (id)init
{
	if(self = [super init]) {
		[self setSelectionIndex:NSNotFound];
		
		_children = [[NSMutableArray array] retain];
	}
	
	return self;
}
- (void)dealloc
{
	[self setSelectionIndex:NSNotFound];
	
	[_children release];
	
	[super dealloc];
}

+ (NSSet *)keyPathsForValuesAffectingIsPlayed
{
	return [NSSet setWithObjects:@"currentTrack", @"currentTrack.isPlayed", nil];
}

- (void)setSelectionIndex:(unsigned)index
{
	if(index == selectionIndex) return;
	if([_children count] <= index && index != NSNotFound) return;
	
	if(index == selectionIndex && index != NSNotFound) {
		id new = [_children objectAtIndex:index];
		if(new == selectedComponent) {
			return;
		}
	}
	
	XspfQTComponent *newSelection = nil;
	if(index != NSNotFound) {
		newSelection = [_children objectAtIndex:index];
	}
	if(selectedComponent != newSelection) {
		[selectedComponent deselect];
		[self setCurrentTrack:newSelection];
		[selectedComponent select];
	}
	
	selectionIndex = index;
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
	return _children;
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
	[_children insertObject:child atIndex:index];
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
	if(![_children containsObject:child]) {
		NSLog(@"Can not find child.(%@)", child);
		return;
	}
	
	NSUInteger index = [_children indexOfObject:child];
	
	[self willChangeValueForKey:@"children"];
	[[child retain] autorelease];
	[child setParent:nil];
	[_children removeObject:child];
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
	unsigned num = [_children count];
	[self insertChild:child atIndex:num];
}
- (void)removeChildAtIndex:(unsigned)index
{
	id child = [_children objectAtIndex:index];
	[self removeChild:child];
}

- (NSString *)description
{
	return [_children description];
}

- (void)setCurrentTrack:(XspfQTComponent *)track
{
	selectedComponent = track;
}
- (XspfQTComponent *)currentTrack
{
	return selectedComponent;
}

- (NSURL *)movieLocation
{
	return [[self currentTrack] movieLocation];
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
