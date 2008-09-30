//
//  XspfQTComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTComponent.h"
#import "XspfQTPlaceholderComponent.h"

@implementation XspfQTComponent

static NSString *const XspfQTComponentXMLStringCodingKey = @"XspfQTComponentXMLStringCodingKey";

+ (id) allocWithZone:(NSZone *) zone
{
	if ([self class] == [XspfQTComponent class]) {
		return [XspfQTPlaceholderComponent sharedInstance];
	}
	
	return [super allocWithZone:zone];
}

+ (id)xspfPlaylist
{
	return [XspfQTPlaceholderComponent xspfPlaylist];
}
+ (id)xspfTrackList
{
	return [XspfQTPlaceholderComponent xspfTrackList];
}
+ (id)xspfComponentWithXMLElementString:(NSString *)string error:(NSError **)outError
{
	return [XspfQTPlaceholderComponent xspfComponentWithXMLElementString:string error:outError];
}
+ (id)xspfComponemtWithXMLElement:(NSXMLElement *)element
{
	return [[[self alloc] initWithXMLElement:element] autorelease];
}
- (id)initWithXMLElement:(NSXMLElement *)element
{
	[super init];
	[self release];
	
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}
- (void)dealloc
{
	[title release];
	[selectionIndexPath release];
	
	[super dealloc];
}

- (NSXMLElement *)XMLElement
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}

- (QTMovie *)qtMovie
{
	return nil;
}
- (NSDate *)duration
{
	return nil;
}
- (XspfQTComponent *)parent
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
- (NSUInteger)indexOfChild:(XspfQTComponent *)child
{
	return [[self children] indexOfObject:child];
}
- (XspfQTComponent *)childAtIndex:(NSUInteger)index
{
	return [[self children] objectAtIndex:index];
}


- (void)setParent:(XspfQTComponent *)new
{
	parent = new;
}
- (void)addChild:(XspfQTComponent *)child
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)removeChild:(XspfQTComponent *)child
{
	[self doesNotRecognizeSelector:_cmd];
}
- (void)insertChild:(XspfQTComponent *)child atIndex:(unsigned)index
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
- (unsigned)selectionIndex
{
	[self doesNotRecognizeSelector:_cmd];
	
	return NSNotFound;
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
	
	XspfQTComponent *firstIndexedChild = [[self children] objectAtIndex:firstIndex];
	if(length != 1) {
		NSIndexPath *deletedFirstIndex = nil;
		unsigned *indexP = NULL;
		@try {
			indexP = calloc(sizeof(unsigned), length);
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
- (XspfQTComponent *)currentTrack
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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	NSString *string = [[self XMLElement] XMLString];
	[aCoder encodeObject:string forKey:XspfQTComponentXMLStringCodingKey];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	[super init];
	[self autorelease];
	
	id string = [aDecoder decodeObjectForKey:XspfQTComponentXMLStringCodingKey];
	
	NSError *error = nil;
	NSXMLElement *element = [[[NSXMLElement alloc] initWithXMLString:string error:&error] autorelease];
	if(error) {
		NSLog(@"%@", error);
		return nil;
	}
	
	return [[[self class] alloc] initWithXMLElement:element];
}

- (NSUInteger)hash
{
	return [[self title] hash];
}
- (BOOL)isEqual:(id)other
{
	if(![other isMemberOfClass:[self class]]) return NO;
	if(![[self title] isEqualToString:[other title]]) return NO;
	
	return YES;
}

@end
