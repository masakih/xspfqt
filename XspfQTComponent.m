//
//  XspfQTComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTComponent.h"
#import "XspfQTPlaceholderComponent.h"

NSString *XspfQTXMLTrackElementName = @"track";
NSString *XspfQTXMLTrackListElementName = @"trackList";
NSString *XspfQTXMLPlaylistElementName = @"playlist";
NSString *XspfQTXMLTitleElementName = @"title";
NSString *XspfQTXMLLocationElementName = @"location";
NSString *XspfQTXMLDurationElementName = @"duration";

NSString *XspfQTXMLExtensionElementName = @"extension";
NSString *XspfQTXMLApplicationAttributeName = @"application";

NSString *XspfQTXMLNamespaceseURI = @"http://masakih.com";
NSString *XspfQTXMLNamespacesePrefix = @"hm";
NSString *XspfQTXMLAliasElement = @"hm:alias";
NSString *XspfQTXMLThumbnailElementName = @"hm:thumbnail";
NSString *XspfQTXMLThumbnailTrackNumAttributeName = @"trackNumber";
NSString *XspfQTXMLThumbnailTimeAttributeName = @"time";

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
+ (id)xspfTrackWithLocation:(NSURL *)location
{
	return [XspfQTPlaceholderComponent xspfTrackWithLocation:location];
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
- (void)setTitle:(NSString *)new
{
	if([title isEqualToString:new]) return;
	
	[title autorelease];
	title = [new copy];
}
- (NSString *)title
{
	return title;
}
- (void)setDuration:(NSDate *)duration {}
- (NSDate *)duration { return nil; }
- (NSURL *)movieLocation
{
	return nil;
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

@implementation XspfQTComponent(XspfComponentOtherMethods)
#pragma mark #### XspfComponentSelection ####
- (void)setIsSelected:(BOOL)flag
{
	isSelected = flag;
}
- (BOOL)isSelected
{
	return isSelected;
}
- (void)select
{
	[self setIsSelected:YES];
}
- (void)deselect
{
	[self setIsSelected:NO];
}
- (BOOL)setSelectionIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger length = [indexPath length];
	if(length == 0) {
		return NO;
	}
	NSUInteger firstIndex = [indexPath indexAtPosition:0];
	if(firstIndex > [self childrenCount]) {
		return NO;
	}
	
	XspfQTComponent *firstIndexedChild = [[self children] objectAtIndex:firstIndex];
	if(length != 1) {
		NSIndexPath *deletedFirstIndex = nil;
		NSUInteger *indexP = NULL;
		@try {
			indexP = calloc(sizeof(NSUInteger), length);
			if(!indexP) {
				[NSException raise:NSMallocException
							format:@"Not enough memory"];
			}
			[indexPath getIndexes:indexP];
			deletedFirstIndex = [NSIndexPath indexPathWithIndexes:indexP + 1
														   length:length - 1];
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
- (void)setCurrentTrackDuration:(NSDate *)duration
{
	[[self currentTrack] setDuration:duration];
}
- (NSDate *)currentTrackDuration
{
	return [[self currentTrack] duration];
}

#pragma mark #### XspfConainerComponent ####
- (void)setParent:(XspfQTComponent *)new
{
	parent = new;
}
- (XspfQTComponent *)parent
{
	return parent;
}
- (NSArray *)children
{
	return nil;
}
- (NSUInteger)childrenCount
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

@end

@implementation XspfQTComponent(XspfThumbnailSupport)
- (void)setThumbnailTrackNum:(NSUInteger)trackNum timeIntarval:(NSTimeInterval)timeIntarval;
{
	if(parent) {
		[parent setThumbnailTrackNum:trackNum timeIntarval:timeIntarval];
	}
}
- (void)setThumbnailComponent:(XspfQTComponent *)item timeIntarval:(NSTimeInterval)timeIntarval
{
	if(parent) {
		[parent setThumbnailComponent:item timeIntarval:timeIntarval];
	}
}
- (XspfQTComponent *)thumbnailTrack
{
	if(parent) {
		return [parent thumbnailTrack];
	}
	return nil;
}
- (NSTimeInterval)thumbnailTimeInterval
{
	if(parent) {
		return [parent thumbnailTimeInterval];
	}
	return DBL_MIN;
}
- (void)removeThumbnailFrame
{
	if(parent) {
		[parent removeThumbnailFrame];
	}
}
@end
