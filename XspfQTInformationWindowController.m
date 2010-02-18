//
//  XspfQTInformationWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/14.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTInformationWindowController.h"
#import "XspfQTDocument.h"


static NSString *const XspfQTDocumentQtMovieKeyPath = @"playingMovie";
static NSString *const XspfQTCurrentTrackKey = @"currentTrack";

@implementation XspfQTInformationWindowController
static XspfQTInformationWindowController *sharedInstance = nil;

+ (XspfQTInformationWindowController *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
			sharedInstance = [[super allocWithZone:NULL] init];
		}
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
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

+ (NSSet *)keyPathsForValuesAffectingMovieAttributes
{
	return [NSSet setWithObject:XspfQTCurrentTrackKey];
}
+ (NSSet *)keyPathsForValuesAffectingSoundTrackAttributes
{
	return [NSSet setWithObject:XspfQTCurrentTrackKey];
}
+ (NSSet *)keyPathsForValuesAffectingVideoTrackAttributes
{
	return [NSSet setWithObject:XspfQTCurrentTrackKey];
}
- (void)notify
{
	[self willChangeValueForKey:XspfQTCurrentTrackKey];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:XspfQTCurrentTrackKey
			   afterDelay:0.0];
}
- (void)currentDocumentDidChangeNotification:(id)notification
{
	[self willChangeValueForKey:@"currentDocument"];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:@"currentDocument"
			   afterDelay:0.0];
}

- (void)windowDidLoad
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(currentDocumentDidChangeNotification:)
			   name:NSWindowDidBecomeMainNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(currentDocumentDidChangeNotification:)
			   name:NSWindowDidResignMainNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSWindowDidResizeNotification
			 object:nil];
	
	
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
			  forKeyPath:XspfQTDocumentQtMovieKeyPath
				 options:0
				 context:NULL];
		[observedDocs addObject:doc];
	}
}
- (id)currentDocument
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	[self addObservingDocument:doc];
	
	return doc;
}
- (id)currentTrack
{
	id doc = [self currentDocument];
	
	return [doc valueForKeyPath:@"trackList.currentTrack"];
}
- (id)movieAttributes
{
	id doc = [self currentDocument];
	
	return [doc valueForKeyPath:@"playingMovie.movieAttributes"];
}

- (id)trackAttributesByType:(NSString *)type
{
	id doc = [self currentDocument];
	
	id movie = [doc valueForKeyPath:XspfQTDocumentQtMovieKeyPath];
	NSArray *tracks = [movie tracksOfMediaType:type];
	if(!tracks || [tracks count] == 0) return nil;
	
	return [[tracks objectAtIndex:0] trackAttributes];
}
- (id)soundTrackAttributes
{
	return [self trackAttributesByType:QTMediaTypeSound];
}
- (id)videoTrackAttributes
{
	return [self trackAttributesByType:QTMediaTypeVideo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:XspfQTDocumentQtMovieKeyPath]) {
		[self notify];
	}
}

- (void)xspfDocumentWillCloseNotification:(id)notification
{
	id doc = [notification object];
	
	if(![observedDocs containsObject:doc]) return;
	
	[doc removeObserver:self forKeyPath:XspfQTDocumentQtMovieKeyPath];
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
