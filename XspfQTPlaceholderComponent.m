//
//  XspfQTPlaceholderComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/06.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTPlaceholderComponent.h"
#import "XspfQTPlaylist.h"
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
+ (id)xspfComponentWithXMLElementString:(NSString *)string error:(NSError **)outError
{
	NSError *error = nil;
	NSXMLElement *element = [[[NSXMLElement alloc] initWithXMLString:string error:&error] autorelease];
	if(error) {
		if(outError) {
			*outError = error;
		}
		[self autorelease];
		return nil;
	}
	
	id component = [XspfQTComponent xspfComponemtWithXMLElement:element];
	
	return component;
}
+ (id)xspfPlaylist
{
	id newTrackList = [self xspfTrackList];
	if(!newTrackList) return nil;
	
	NSError *error = nil;
	id newPlaylist = [self xspfComponentWithXMLElementString:@"<playlist></playlist>" error:&error];
	if(!newPlaylist) {
		if(error) {
			NSLog(@"%@", error);
		}
		return nil;
	}
	[newPlaylist addChild:newTrackList];
	
	return newPlaylist;
}
+ (id)xspfTrackList
{
	NSError *error = nil;
	id newTrackList = [self xspfComponentWithXMLElementString:@"<trackList></trackList>" error:&error];
	if(!newTrackList) {
		if(error) {
			NSLog(@"%@", error);
		}
		return nil;
	}
	
	[newTrackList setTitle:@"Untitled"];
	
	return newTrackList;
}

- (id)initWithXMLElement:(NSXMLElement *)element
{
	[super init];
	[self autorelease];
	
	NSString *name = [element name];
	if(!name) return nil;
	if([name isEqualToString:@""]) return nil;
	
	if([name isEqualToString:XspfQTXMLTrackElementName]) {
		return [[XspfQTTrack alloc] initWithXMLElement:element];
	}
	if([name isEqualToString:XspfQTXMLTrackListElementName]) {
		return [[XspfQTTrackList alloc] initWithXMLElement:element];
	}
	if([name isEqualToString:XspfQTXMLPlaylistElementName]) {
		return [[XspfQTPlaylist alloc] initWithXMLElement:element];
	}
	
	return nil;
}
@end
