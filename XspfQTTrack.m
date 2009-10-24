//
//  XspfQTTrack.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTTrack.h"

#import <QTKit/QTTime.h>
#import "NSURL-XspfQT-Extensions.h"
#import "NSPathUtilities-XspfQT-Extensions.h"

@interface XspfQTTrack (Private)
- (void)setSavedDateWithQTTime:(QTTime)qttime;
@end

@implementation XspfQTTrack
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:XspfQTXMLLocationElementName];
	if(!elems || [elems count] == 0) {
		[self release];
		return nil;
	}
	
	NSString *loc = [[elems objectAtIndex:0] stringValue];
	[self setLocationString:loc];
	
	NSString *t;
	elems = [element elementsForName:XspfQTXMLTitleElementName];
	if(!elems || [elems count] == 0) {
		t = [[self locationString] lastPathComponent];
		t = [t stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	} else {
		t = [[elems objectAtIndex:0] stringValue];
	}
	[self setTitle:t];
	
	elems = [element elementsForName:XspfQTXMLDurationElementName];
	if(elems && [elems count] != 0) {
		t = [[elems objectAtIndex:0] stringValue];
		NSTimeInterval ti = [t doubleValue] / 1000;
		QTTime q = QTMakeTimeWithTimeInterval(ti);
		[self setSavedDateWithQTTime:q];
	}
	
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
			
			id aliasString = [[[myExtension elementsForName:XspfQTXMLAliasElement] objectAtIndex:0] stringValue];
			if(!aliasString) break;
			
			NSData *aliasData = [aliasString propertyList];
			if(![aliasData isKindOfClass:[NSData class]]) break;
						
			NSString *loc = [aliasData resolvedPath];
			if(loc) {
				[self setLocation:[NSURL fileURLWithPath:loc]];
			}
		} while(NO);
	}
	
	return self;
}
- (void)dealloc
{
	[location release];
	[self setDuration:nil];
	
	[super dealloc];
}
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:XspfQTXMLTrackElementName];
	
	id locElem = [NSXMLElement elementWithName:XspfQTXMLLocationElementName stringValue:[self locationString]];
	if(locElem) {
		[node addChild:locElem];
	}
	id titleElem = [NSXMLElement elementWithName:XspfQTXMLTitleElementName stringValue:[self title]];
	if(titleElem) {
		[node addChild:titleElem];
	}
	
	id d = [self duration];
	if(d) {
		NSTimeInterval t = [d timeIntervalSince1970];
		t += [[NSTimeZone systemTimeZone] secondsFromGMT];
		unsigned long long scaledT = (unsigned long long)t;
		scaledT *= 1000;
		id durationElem = [NSXMLElement elementWithName:XspfQTXMLDurationElementName
											stringValue:[NSString stringWithFormat:@"%qu", scaledT]];
		if(durationElem) {
			[node addChild:durationElem];
		}
	}
	
	do {
		if([[self location] isFileURL]) {
			NSString *path = [[self location] path];
			NSData *aliasData = [path aliasData];
			if(!aliasData) break;
			
			id aliasElem = [NSXMLElement elementWithName:XspfQTXMLAliasElement
											 stringValue:[NSString stringWithFormat:@"%@", aliasData]];
			if(!aliasElem) break;
			id applicationAttr = [NSXMLElement attributeWithName:XspfQTXMLApplicationAttributeName
													 stringValue:XspfQTXMLNamespaceseURI];
			if(!applicationAttr) break;
			id extensionElem = [NSXMLElement elementWithName:XspfQTXMLExtensionElementName
													children:[NSArray arrayWithObject:aliasElem]
												  attributes:[NSArray arrayWithObject:applicationAttr]];
			if(extensionElem) {
				[node addChild:extensionElem];
			}
		}
	} while(NO);
	
	return node;
}
- (void)setLocation:(NSURL *)loc
{
	if([location isEqualUsingLocalhost:loc]) return;
	
	[location autorelease];
	location = [loc retain];
}
- (NSURL *)location
{
	return location;
}
- (void)setLocationString:(NSString *)loc
{
	[self setLocation:[NSURL URLWithString:loc]];
}
- (NSString *)locationString
{
	NSString *str = [[self location] absoluteString];
	
	return [str stringByReplacingOccurrencesOfString:@"//localhost/"
										  withString:@"///"];
}

- (void)setSavedDateWithQTTime:(QTTime)qttime
{
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	[self setDuration:[t transformedValue:[NSValue valueWithQTTime:qttime]]];
}
- (NSDate *)savedDate
{
	return duration;
}
- (void)setDuration:(NSDate *)newDuration
{
	[duration autorelease];
	duration = [newDuration retain];
}
- (NSDate *)duration
{
	return duration;
}
- (NSURL *)movieLocation
{
	return location;
}
- (void)setIsPlayed:(BOOL)state
{
	isPlayed = state;
}
- (BOOL)isPlayed
{
	return isPlayed;
}
- (void)next
{
	[[self parent] next];
}
- (void)previous
{
	[[self parent] previous];
}

- (BOOL)isEqual:(id)other
{
	if(![super isEqual:other]) return NO;
	if(![[self locationString] isEqual:[other locationString]]) return NO;
	
	return YES;
}

#pragma mark#### NSCoding ####
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	NSDictionary *dict =
	[NSDictionary dictionaryWithObjectsAndKeys:[self title], @"XspfQTTrackTitle",
	 [self location], @"XspfQTTrackLocation",
	 [self duration], @"XspfQTTrackDuration",
	 nil];
	
	[aCoder encodeObject:dict forKey:@"XspfQTTrackCodingKey"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	[super init];
	[self autorelease];
	
	id dict = [aDecoder decodeObjectForKey:@"XspfQTTrackCodingKey"];
	
	[self setTitle:[dict objectForKey:@"XspfQTTrackTitle"]];
	[self setDuration:[dict objectForKey:@"XspfQTTrackDuration"]];
	[self setLocation:[dict objectForKey:@"XspfQTTrackLocation"]];
	
	NSXMLElement *element = [self XMLElement];
	
	return [[[self class] alloc] initWithXMLElement:element];
}


- (NSString *)description
{
	return [NSString stringWithFormat:@"Title:(%@)\nLocation:(%@)",
			[self title], [self location]];
}
@end
