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
	}
	
	return self;
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
	
	for(id n in [self children]) {
		[node addChild:[n XMLElement]];
	}
	
	return node;
}


@end
