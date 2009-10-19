//
//  XspfQTPlaylist.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/28.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTPlaylist.h"


@interface XspfQTPlaylist (XspfThumnailSupport)
- (void)setThumnailTrackNum:(NSUInteger)trackNum;
- (void)setThumnailTime:(NSDate *)time;
- (XspfQTComponent *)trackForTrackNum:(NSUInteger)trackNum;

@end

@implementation XspfQTPlaylist
- (id)initWithXMLElement:(NSXMLElement *)element
{
	if(self = [super init]) {		
		NSArray *elems = [element elementsForName:@"trackList"];
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
		elems = [element elementsForName:@"title"];
		if(elems && [elems count] != 0) {
			t = [[elems objectAtIndex:0] stringValue];
			[self setTitle:t];
		}
		
		///
		thumnailTrackNum = NSNotFound;
	}
	
	return self;
}

- (void)dealloc
{
	[self setThumnailTime:nil];
	[super dealloc];
}

- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:@"playlist"];
	[node addAttribute:[NSXMLNode attributeWithName:@"version"
										stringValue:@"1"]];
	[node addAttribute:[NSXMLNode attributeWithName:@"xmlns"
										stringValue:@"http://xspf.org/ns/0/"]];
	
	[node addAttribute:[NSXMLNode attributeWithName:[NSString stringWithFormat:@"xmlns:%@", XspfQTXMLNamespacesePrefix]
										stringValue:XspfQTXMLNamespaceseURI]];
	
	if([self title]) {
		id t = [NSXMLElement elementWithName:@"title"
								 stringValue:[self title]];
		[node addChild:t];
	}
	
	do {
		if(thumnailTrackNum != NSNotFound) {			
			id trackNumberAttr = [NSXMLElement attributeWithName:@"trackNumber"
											 stringValue:[NSString stringWithFormat:@"%u", thumnailTrackNum]];
			if(!trackNumberAttr) break;
			
			id timeAttr = nil;
			if(thumnailTime) {
				NSTimeInterval t = [thumnailTime timeIntervalSince1970];
				t += [[NSTimeZone systemTimeZone] secondsFromGMT];
				unsigned long long scaledT = (unsigned long long)(t * 1000);
				timeAttr = [NSXMLElement attributeWithName:@"time"
												  stringValue:[NSString stringWithFormat:@"%qu", scaledT]];
				if(!timeAttr) break;
			}
			
			id thumnailElem = [NSXMLElement elementWithName:@"hm:thumnail"
												   children:[NSArray array]
												 attributes:[NSArray arrayWithObjects:trackNumberAttr, timeAttr, nil]];
			if(!thumnailElem) break;
			
			id applicationAttr = [NSXMLElement attributeWithName:@"application"
													 stringValue:XspfQTXMLNamespaceseURI];
			if(!applicationAttr) break;
			id extensionElem = [NSXMLElement elementWithName:@"extension"
													children:[NSArray arrayWithObject:thumnailElem]
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

@implementation XspfQTPlaylist (XspfThumnailSupport)

- (void)setThumnailTrackNum:(NSUInteger)trackNum
{
	thumnailTrackNum = trackNum;
}
- (void)setThumnailTime:(NSDate *)time
{
	[thumnailTime autorelease];
	thumnailTime = [time retain];
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

- (void)setThumnailTrackNum:(NSUInteger)trackNum time:(NSDate *)time
{
	XspfQTComponent *t = [self trackForTrackNum:trackNum];
	
	if(!t) return;
	
	[self setThumnailTrackNum:trackNum];
	[self setThumnailTime:time];	
}
- (void)setThumnailComponent:(XspfQTComponent *)item time:(NSDate *)time
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
	
	[self setThumnailTrackNum:sum];
	[self setThumnailTime:time];
}
	
- (XspfQTComponent *)thumnailTrack
{
	if(thumnailTrackNum == NSNotFound) return nil;
	
	return [self trackForTrackNum:thumnailTrackNum];
}
- (NSDate *)thumnailTime
{
	if(thumnailTrackNum == NSNotFound) return nil;
	
	return thumnailTime;
}
@end
