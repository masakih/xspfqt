//
//  XspfMovieWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfMovieWindowController.h"
#import "XspfDocument.h"
#import "XspfTrackList.h"
#import "XspfFullScreenWindow.h"


@interface XspfMovieWindowController (Private)
- (NSSize)fitSizeToSize:(NSSize)toSize;
- (NSWindow *)fullscreenWindow;
@end

@implementation XspfMovieWindowController

static const float sVolumeDelta = 0.2;
static NSString *const kCurrentIndexKeyPath = @"trackList.currentIndex";

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if(self = [super initWithWindowNibName:@"XspfDocument"]) {
		//
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(applicationWillTerminate:)
				   name:NSApplicationWillTerminateNotification
				 object:NSApp];
		
		updateTime = [NSTimer scheduledTimerWithTimeInterval:0.3
													  target:self
													selector:@selector(updateTimeIfNeeded:)
													userInfo:NULL
													 repeats:YES];
	}
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
		
	[fullscreenWindow release];
	
	[qtMovie release];
		
	[super dealloc];
}

- (void)awakeFromNib
{
	prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
	
	id d = [self document];
//	NSLog(@"Add Observed! %@", d);
	[d addObserver:self
		forKeyPath:kCurrentIndexKeyPath
		   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
		   context:NULL];
	
	
	id window = [self window];
	NSRect frame = [window frame];
	NSSize newSize = [self fitSizeToSize:frame.size];
	frame.size = newSize;
	frame.origin.y -= frame.size.height - newSize.height;
	
	[window setFrame:frame display:YES];
	
	[self play];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
//	NSLog(@"Observed!");
	if([keyPath isEqual:kCurrentIndexKeyPath]) {
		id old = [change objectForKey:NSKeyValueChangeOldKey];
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		if([old isEqual:new]) return;
		[self setQtMovie:[self valueForKeyPath:@"document.trackList.qtMovie"]];
		return;
	}
	
	[super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];
}

- (void)setQtMovie:(QTMovie *)qt
{
	if(qtMovie == qt) return;
	if([qtMovie isEqual:qt]) return;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	if(qtMovie) {
		[nc removeObserver:self name:nil object:qtMovie];
	}
	if(qt) {
		[nc addObserver:self selector:@selector(didEndMovie:) name:QTMovieDidEndNotification object:qt];
	}
	
	if(qtMovie) {
		[qt setVolume:[qtMovie volume]];
		[qt setMuted:[qtMovie muted]];
	}
	[qtMovie autorelease];
	qtMovie = [qt retain];
	[self synchronizeWindowTitleWithDocumentName];
	
	[self play];
}
- (QTMovie *)qtMovie
{
	return qtMovie;
}


- (NSSize)fitSizeToSize:(NSSize)toSize
{
	QTMovie *curMovie = [self qtMovie];
	if(!curMovie) return toSize;
	
	NSSize qtViewSize = [qtView frame].size;
	NSSize currentWindowSize = [[self window] frame].size;
	
	NSSize delta = NSMakeSize(currentWindowSize.width - qtViewSize.width,
							  currentWindowSize.height - qtViewSize.height);
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	
	float targetViewWidth = toSize.width - delta.width;
	float targetViewHeight = targetViewWidth * (movieSize.height / movieSize.width);
	
	targetViewWidth += delta.width;
	targetViewHeight += delta.height;
	
	NSSize newSize = NSMakeSize(targetViewWidth, targetViewHeight);
	
	return newSize;
}

- (void)play
{
	[qtView performSelectorOnMainThread:@selector(play:) withObject:self waitUntilDone:NO];
}

- (void)enterFullScreen
{
//	if([qtView respondsToSelector:@selector(isInFullScreenMode)]) {
//		// System is 10.5 or later.
//		id op = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
//											forKey:@"NSFullScreenModeAllScreens"];
//		[qtView enterFullScreenMode:[NSScreen mainScreen]
//						withOptions:op];
//		NSLog(@"Use enterFullScreen:withOptions:");
//	} else {
		NSWindow *w = [self fullscreenWindow];
		
		nomalModeSavedFrame = [qtView frame];
		
		[w setContentView:qtView];
		
//		[NSMenu setMenuBarVisible:NO];
		SetSystemUIMode (kUIModeAllHidden, kUIOptionAutoShowMenuBar);
		
		[[self window] orderOut:self];
		[w makeKeyAndOrderFront:self];
		[w makeFirstResponder:qtView];
//	}
	
}
- (void)exitFullScreen
{
//	if([qtView respondsToSelector:@selector(isInFullScreenMode)]) {
//		// System is 10.5 or later.
//		[qtView exitFullScreenModeWithOptions:nil];
//	} else {
		NSWindow *w = [self fullscreenWindow];
		
		[qtView retain];
		{
			[qtView removeFromSuperview];
			[qtView setFrame:nomalModeSavedFrame];
			[[[self window] contentView] addSubview:qtView];
		}
		[qtView release];
		
		[NSMenu setMenuBarVisible:YES];
		[w orderOut:self];
		[[self window] makeKeyAndOrderFront:self];
		[w makeFirstResponder:qtView];
//	}
}
- (IBAction)turnUpVolume:(id)sender
{
	NSNumber *cv = [self valueForKeyPath:@"qtMovie.volume"];
	cv = [NSNumber numberWithFloat:[cv floatValue] + sVolumeDelta];
	[self setValue:cv forKeyPath:@"qtMovie.volume"];
}
- (IBAction)turnDownVolume:(id)sender
{
	NSNumber *cv = [self valueForKeyPath:@"qtMovie.volume"];
	cv = [NSNumber numberWithFloat:[cv floatValue] - sVolumeDelta];
	[self setValue:cv forKeyPath:@"qtMovie.volume"];
}
- (IBAction)toggleFullScreenMode:(id)sender
{
	if(fullscreenMode) {
		[self exitFullScreen];
		fullscreenMode = NO;
	} else {
		[self enterFullScreen];
		fullscreenMode = YES;
	}
}

- (NSWindow *)fullscreenWindow
{
	if(fullscreenWindow) return fullscreenWindow;
	
	NSRect mainScreenRect = [[NSScreen mainScreen] frame];
	fullscreenWindow = [[XspfFullScreenWindow alloc] initWithContentRect:mainScreenRect
															   styleMask:NSBorderlessWindowMask
																 backing:NSBackingStoreBuffered
																   defer:YES];
	[fullscreenWindow setReleasedWhenClosed:NO];
	[fullscreenWindow setBackgroundColor:[NSColor blackColor]];
	[fullscreenWindow setDelegate:self];
	
	return fullscreenWindow;
}

- (void)didEndMovie:(id)notification
{
	[[[self document] trackList] next];
//	[self setQtMovie:[[[self document] trackList] qtMovie]];
}
- (void)updateTimeIfNeeded:(id)timer
{
	QTMovie *qt = [self qtMovie];
	if(qt) {
		[qt willChangeValueForKey:@"currentTime"];
		[qt didChangeValueForKey:@"currentTime"];
	}
	
	// Hide cursor and controller, if mouse didn't move for 3 seconds.
	NSPoint mouse = [NSEvent mouseLocation];
	if(!NSEqualPoints(prevMouse, mouse)) {
		prevMouse = mouse;
		[prevMouseMovedDate autorelease];
		prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
	} else if(fullscreenMode && [prevMouseMovedDate timeIntervalSinceNow] < -3.0 ) {
		[NSCursor setHiddenUntilMouseMoves:YES];
		//
		// hide controller.
	}
}

- (void)cancelOperation:(id)sender
{
	if(fullscreenMode) {
		[self toggleFullScreenMode:self];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	if(fullscreenMode) {
		[self toggleFullScreenMode:self];
	}
	[[self document] removeObserver:self forKeyPath:kCurrentIndexKeyPath];
}


- (BOOL)windowShouldClose:(id)sender
{
	[qtView pause:self];
	[self setQtMovie:nil];
	
	[[self document] removeObserver:self forKeyPath:kCurrentIndexKeyPath];
	[self setShouldCloseDocument:YES];
	
	[updateTime release];
	updateTime = nil;
	
	return YES;
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
	return [self fitSizeToSize:frameSize];
}
@end
