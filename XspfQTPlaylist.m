//
//  XspfQTPlaylist.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/28.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTPlaylist.h"


@interface XspfQTPlaylist (XspfThumbnailSupport)
- (void)setThumbnailTrackNum:(NSUInteger)trackNum;
- (XspfQTComponent *)trackForTrackNum:(NSUInteger)trackNum;

@end

@implementation XspfQTPlaylist
- (id)initWithXMLElement:(NSXMLElement *)element
{
	if(self = [super init]) {		
		NSArray *elems = [element elementsForName:XspfQTXMLTrackListElementName];
		if(!elems) {
			[self release];
			return nil;
		}
				
		for(NSXMLElement *trackListsElem in elems) {
			XspfQTComponent *trackList = [XspfQTComponent xspfComponemtWithXMLElement:trackListsElem];
			if(trackList) {
				[self addChild:trackList];
			}
		}
		
		NSString *t;
		elems = [element elementsForName:XspfQTXMLTitleElementName];
		if(elems && [elems count] != 0) {
			t = [[elems objectAtIndex:0] stringValue];
			[self setTitle:t];
		}
		
		///
		thumbnailTrackNum = NSNotFound;
		thumbnailTimeInterval = DBL_MIN;
		
		////
		elems = [element elementsForName:XspfQTXMLExtensionElementName];
		id myExtension = nil;
		if(elems && [elems count] != 0) {
			for(id extension in elems) {
				id app = [[extension attributeForName:XspfQTXMLApplicationAttributeName] stringValue];
				if([app isEqualToString:XspfQTXMLNamespaceseURI]) {
					myExtension = extension;
					break;
				}
			}
			
			do {
				if(!myExtension) break;
				id elementsArray = [myExtension elementsForName:XspfQTXMLThumbnailElementName];
				if([elementsArray count] == 0) break;
				id thumbnail = [elementsArray objectAtIndex:0];
				if(!thumbnail) break;
				id index = [thumbnail attributeForName:XspfQTXMLThumbnailTrackNumAttributeName];
				if(!index) break;
				id time = [thumbnail attributeForName:XspfQTXMLThumbnailTimeAttributeName];
				if(!time) break;
				
				NSString *t = [time stringValue];
				NSTimeInterval ti = [t doubleValue] / 1000;
				[self setThumbnailTrackNum:[[index stringValue] integerValue] timeIntarval:ti];
			} while(NO);
		}
	}
	
	return self;
}

- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:XspfQTXMLPlaylistElementName];
	[node addAttribute:[NSXMLNode attributeWithName:@"version"
										stringValue:@"1"]];
	[node addAttribute:[NSXMLNode attributeWithName:@"xmlns"
										stringValue:@"http://xspf.org/ns/0/"]];
	
	[node addAttribute:[NSXMLNode attributeWithName:[NSString stringWithFormat:@"xmlns:%@", XspfQTXMLNamespacesePrefix]
										stringValue:XspfQTXMLNamespaceseURI]];
	
	if([self title]) {
		id t = [NSXMLElement elementWithName:XspfQTXMLTitleElementName
								 stringValue:[self title]];
		[node addChild:t];
	}
	
	do {
		if(thumbnailTrackNum != NSNotFound) {			
			id trackNumberAttr = [NSXMLElement attributeWithName:XspfQTXMLThumbnailTrackNumAttributeName
											 stringValue:[NSString stringWithFormat:@"%u", thumbnailTrackNum]];
			if(!trackNumberAttr) break;
			
			id timeAttr = nil;
			if(thumbnailTimeInterval != DBL_MIN) {
				unsigned long long scaledT = (unsigned long long)(thumbnailTimeInterval * 1000);
				timeAttr = [NSXMLElement attributeWithName:XspfQTXMLThumbnailTimeAttributeName
												  stringValue:[NSString stringWithFormat:@"%qu", scaledT]];
				if(!timeAttr) break;
			}
			
			id thumbnailElem = [NSXMLElement elementWithName:XspfQTXMLThumbnailElementName
												   children:[NSArray array]
												 attributes:[NSArray arrayWithObjects:trackNumberAttr, timeAttr, nil]];
			if(!thumbnailElem) break;
			
			id applicationAttr = [NSXMLElement attributeWithName:XspfQTXMLApplicationAttributeName
													 stringValue:XspfQTXMLNamespaceseURI];
			if(!applicationAttr) break;
			id extensionElem = [NSXMLElement elementWithName:XspfQTXMLExtensionElementName
													children:[NSArray arrayWithObject:thumbnailElem]
												  attributes:[NSArray arrayWithObject:applicationAttr]];
			if(extensionElem) {
				[node addChild:extensionElem];
			}
		}
	} while(NO);
	
	for(id n in [self children]) {
		[node addChild:[n XMLElement]];
	}
	
	return node;
}

@end

@implementation XspfQTPlaylist (XspfThumbnailSupport)

- (void)setThumbnailTrackNum:(NSUInteger)trackNum
{
	thumbnailTrackNum = trackNum;
}
- (void)setThumbnailTimeInterval:(NSTimeInterval)interval
{
	thumbnailTimeInterval = interval;
}

- (XspfQTComponent *)trackForTrackNum:(NSUInteger)trackNum
{
	XspfQTComponent *t;
	NSUInteger tracks = 0;
	NSUInteger aCount;
	
	NSEnumerator *iter = [[self children] objectEnumerator];
	for(t in iter) {
		aCount = [t childrenCount];
		if(aCount + tracks > trackNum) {
			break;
		}
		tracks += aCount;
	}
	if(!t) return nil;
	
	NSUInteger aNum = trackNum - tracks;
	if([t childrenCount] < aNum) return nil;
	
	return [t childAtIndex:aNum];
}

- (void)setThumbnailTrackNum:(NSUInteger)trackNum timeIntarval:(NSTimeInterval)timeIntarval
{
	XspfQTComponent *t = [self trackForTrackNum:trackNum];
	
	if(!t) return;
	
	[self setThumbnailTrackNum:trackNum];
	[self setThumbnailTimeInterval:timeIntarval];	
}
- (void)setThumbnailComponent:(XspfQTComponent *)item timeIntarval:(NSTimeInterval)timeIntarval
{
	XspfQTComponent *trackList = [item parent];
	XspfQTComponent *playList = [trackList parent];
	
	if(playList != self) return;
	
	NSUInteger sum = 0;
	XspfQTComponent *t;
	for(t in [self children]) {
		if(t == trackList) break;
		sum += [t childrenCount];
	}
	if(!t) return;
	
	sum += [trackList indexOfChild:item];
	
	[self setThumbnailTrackNum:sum];
	[self setThumbnailTimeInterval:timeIntarval];
}

	
- (XspfQTComponent *)thumbnailTrack
{
	if(thumbnailTrackNum == NSNotFound) return nil;
	
	return [self trackForTrackNum:thumbnailTrackNum];
}
- (NSTimeInterval)thumbnailTimeInterval
{
	return thumbnailTimeInterval;
}
- (void)removeThumbnailFrame
{
	[self setThumbnailTrackNum:NSNotFound];
	[self setThumbnailTimeInterval:DBL_MIN];
}
@end
