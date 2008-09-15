//
//  XspfQTInformationWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/14.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTInformationWindowController.h"
#import "XspfQTDocument.h"


@implementation XspfQTInformationWindowController
static XspfQTInformationWindowController *sharedInstance = nil;

+ (XspfQTInformationWindowController *)sharedInstance
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

#pragma mark-
- (id)init
{
	[super initWithWindowNibName:@"XspfQTImformation"];
	observedDocs = [[NSMutableArray array] retain];
	return self;
}

- (void)windowDidLoad
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSWindowDidBecomeMainNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSWindowDidResignMainNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSApplicationDidBecomeActiveNotification
			 object:NSApp];
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSApplicationDidHideNotification
			 object:NSApp];
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSApplicationDidHideNotification
			 object:NSApp];
	[nc addObserver:self
		   selector:@selector(xspfDocumentWillCloseNotification:)
			   name:XspfQTDocumentWillCloseNotification
			 object:nil];
	
}
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[observedDocs release];
	
	[super dealloc];
}

- (id)currentTrack
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	
	if(![observedDocs containsObject:doc]) {
		[doc addObserver:self
			  forKeyPath:@"trackList.qtMovie"
				 options:0
				 context:NULL];
		[observedDocs addObject:doc];
	}
	
	return [doc valueForKeyPath:@"trackList.currentTrack"];
}
- (id)movieAttributes
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	
	if(![observedDocs containsObject:doc]) {
		[doc addObserver:self
			  forKeyPath:@"trackList.qtMovie"
				 options:0
				 context:NULL];
		[observedDocs addObject:doc];
	}
	
	return [doc valueForKeyPath:@"trackList.qtMovie.movieAttributes"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:@"trackList.qtMovie"]) {
		[self willChangeValueForKey:@"movieAttributes"];
		[self didChangeValueForKey:@"movieAttributes"];
		[self willChangeValueForKey:@"currentTrack"];
		[self didChangeValueForKey:@"currentTrack"];
	}
}

- (void)xspfDocumentWillCloseNotification:(id)notification
{
	id doc = [notification object];
	
	[doc removeObserver:self forKeyPath:@"trackList.qtMovie"];
	[observedDocs removeObject:doc];
	[docController setContent:nil];
}
- (void)notifee:(id)notification
{
	[self willChangeValueForKey:@"movieAttributes"];
	[self didChangeValueForKey:@"movieAttributes"];
	[self willChangeValueForKey:@"currentTrack"];
	[self didChangeValueForKey:@"currentTrack"];
}


@end
