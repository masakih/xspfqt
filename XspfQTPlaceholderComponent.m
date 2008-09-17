//
//  XspfQTPlaceholderComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/06.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTPlaceholderComponent.h"
#import "XspfQTTrackList.h"
#import "XspfQTTrack.h"

@implementation XspfQTPlaceholderComponent
static XspfQTPlaceholderComponent *sharedInstance = nil;

+ (XspfQTPlaceholderComponent *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark ### initializers ###
- (id)initWithXMLElement:(NSXMLElement *)element
{
	NSString *name = [element name];
	if(!name) return nil;
	if([name isEqualToString:@""]) return nil;
	
	if([name isEqualToString:@"trackList"]) {
		return [[XspfQTTrackList alloc] initWithXMLElement:element];
	}
	if([name isEqualToString:@"track"]) {
		return [[XspfQTTrack alloc] initWithXMLElement:element];
	}
	
	return nil;
}
@end