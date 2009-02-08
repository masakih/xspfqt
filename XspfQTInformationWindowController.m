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

- (void)notify
{
	[self willChangeValueForKey:@"movieAttributes"];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:@"movieAttributes"
			   afterDelay:0.0];
	[self willChangeValueForKey:@"currentTrack"];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:@"currentTrack"
			   afterDelay:0.0];
	[self willChangeValueForKey:@"soundTrackAttributes"];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:@"soundTrackAttributes"
			   afterDelay:0.0];
	[self willChangeValueForKey:@"videoTrackAttributes"];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:@"videoTrackAttributes"
			   afterDelay:0.0];
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
			   name:NSWindowDidResizeNotification
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

- (void)addObservingDocument:(id)doc
{
	if(!doc) return;
	
	if(![observedDocs containsObject:doc]) {
		[doc addObserver:self
			  forKeyPath:@"trackList.qtMovie"
				 options:0
				 context:NULL];
		[observedDocs addObject:doc];
	}
}
- (id)currentTrack
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	[self addObservingDocument:doc];
	
	return [doc valueForKeyPath:@"trackList.currentTrack"];
}
- (id)movieAttributes
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	[self addObservingDocument:doc];
	
	return [doc valueForKeyPath:@"trackList.qtMovie.movieAttributes"];
}
- (id)soundTrackAttributes
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	[self addObservingDocument:doc];
	
	id movie = [doc valueForKeyPath:@"trackList.qtMovie"];
	NSArray *soundTracks = [movie tracksOfMediaType:QTMediaTypeSound];
	if(!soundTracks ||[soundTracks count] == 0) return nil;
	
	return [[soundTracks objectAtIndex:0] trackAttributes];
}
- (id)videoTrackAttributes
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	[self addObservingDocument:doc];
	
	id movie = [doc valueForKeyPath:@"trackList.qtMovie"];
	NSArray *videoTracks = [movie tracksOfMediaType:QTMediaTypeVideo];
	if(!videoTracks ||[videoTracks count] == 0) return nil;
	
	return [[videoTracks objectAtIndex:0] trackAttributes];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:@"trackList.qtMovie"]) {
		[self notify];
	}
}

- (void)xspfDocumentWillCloseNotification:(id)notification
{
	id doc = [notification object];
	
	if(![observedDocs containsObject:doc]) return;
	
	[doc removeObserver:self forKeyPath:@"trackList.qtMovie"];
	[observedDocs removeObject:doc];
	[docController setContent:nil];
	[currentTrackController setContent:nil];
	
	[self notify];
}
- (void)notifee:(id)notification
{
	[self notify];
}

@end
