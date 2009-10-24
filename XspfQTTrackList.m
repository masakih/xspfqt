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
		NSArray *elems = [element elementsForName:XspfQTXMLTrackElementName];
		if(!elems) {
			[self release];
			return nil;
		}
		
		for(NSXMLElement *trackElem in elems) {
			XspfQTComponent *track = [XspfQTComponent xspfComponemtWithXMLElement:trackElem];
			if(track) {
				[self addChild:track];
			}
		}
	}
	
	return self;
}
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:XspfQTXMLTrackListElementName];
	
	for(id n in [self children]) {
		[node addChild:[n XMLElement]];
	}
	
	return node;
}

@end
