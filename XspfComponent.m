//
//  XspfComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfComponent.h"
#import "XspfPlaceholderComponent.h"

@implementation XspfComponent

+ (id) allocWithZone : (NSZone *) zone
{
	if ([self class] == [XspfComponent class]) {
		return [XspfPlaceholderComponent sharedInstance];
	}
	
	return [super allocWithZone : zone];
}

+ (id)xspfComponemtWithXMLElement:(NSXMLElement *)element
{
	return [[[self alloc] initWithXMLElement:element] autorelease];
}
- (id)initWithXMLElement:(NSXMLElement *)element
{
	[super init];
	[self doesNotRecognizeSelector:_cmd];
	
	[self release];
	
	return nil;
}

- (NSXMLElement *)XMLElement
{
	[self doesNotRecognizeSelector:_cmd];
}

- (QTMovie *)qtMovie
{
	return nil;
}
- (NSDate *)duration
{
	return nil;
}
- (XspfComponent *)parent
{
	return parent;
}
- (NSArray *)children
{
	return nil;
}
- (unsigned)childrenCount
{
	return [[self children] count];
}
- (BOOL)isLeaf
{
	return YES;
}

- (void)setParent:(XspfComponent *)new
{
	parent = new;
}
- (void)addChild:(XspfComponent *)child
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)removeChild:(XspfComponent *)child
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)insertChild:(XspfComponent *)child atIndex:(unsigned)index
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)removeChildAtIndex:(unsigned)index
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)setTitle:(NSString *)new
{
	if(title == new) return;
	if([title isEqualTo:new]) return;
	
	[title autorelease];
	title = [new copy];
}
- (NSString *)title
{
	return title;
}
- (BOOL)isSelected
{
	return isSelected;
}
- (void)select
{
	[self willChangeValueForKey:@"isSelected"];
	isSelected = YES;
	[self didChangeValueForKey:@"isSelected"];
}
- (void)deselect
{
	[self willChangeValueForKey:@"isSelected"];
	isSelected = NO;
	[self didChangeValueForKey:@"isSelected"];
}
- (void)setSelectionIndex:(unsigned)index
{
	[self doesNotRecognizeSelector:_cmd];
	
	// 現在値と違うなら現在値をdeselect
	
	// 新しい値をselect
}
- (BOOL)setSelectionIndexPath:(NSIndexPath *)indexPath
{
	unsigned length = [indexPath length];
	if(length == 0) {
		return NO;
	}
	unsigned firstIndex = [indexPath indexAtPosition:0];
	if(firstIndex > [self childrenCount]) {
		return NO;
	}
	
	XspfComponent *firstIndexedChild = [[self children] objectAtIndex:firstIndex];
	if(length != 1) {
		NSIndexPath *deletedFirstIndex = nil;
		unsigned *indexP = NULL;
		@try {
			indexP = calloc(sizeof(unsigned), length - 1);
			if(!indexP) {
				[NSException raise:NSMallocException
							format:@"Not enough memory"];
			}
			[indexPath getIndexes:indexP];
			deletedFirstIndex = [NSIndexPath indexPathWithIndexes:indexP + 1
														   length:length - 1];
		}
		@catch (id ex) {
			@throw;
		}
		@finally{
			free(indexP);
		}
		if(!deletedFirstIndex ||
		   ![firstIndexedChild setSelectionIndexPath:deletedFirstIndex]) {
			return NO;
		}
	} else {
		[self setSelectionIndex:firstIndex];
	}
	if(!isSelected) {
		[self select];
	}
	[selectionIndexPath autorelease];
	selectionIndexPath = [indexPath retain];
	
	return YES;
}
- (NSIndexPath *)selectionIndexPath
{
	return selectionIndexPath;
}
- (void)setIsPlayed:(BOOL)state {} // do nothing.
- (BOOL)isPlayed
{
	return NO;
}
- (XspfComponent *)currentTrack
{
	return self;
}
- (void)next
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)previous
{
	[self doesNotRecognizeSelector:_cmd];
}

@end
