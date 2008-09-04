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
- (void)sizeTofitWidnow;
- (NSSize)fitSizeToSize:(NSSize)toSize;
- (NSWindow *)fullscreenWindow;
@end

@implementation XspfMovieWindowController

#pragma mark ### Static variables ###
static const float sVolumeDelta = 0.2;
static NSString *const kCurrentIndexKeyPath = @"trackList.currentIndex";

- (id)init
{
	if(self = [super initWithWindowNibName:@"XspfDocument"]) {
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
	[updateTime release];
	
	[prevMouseMovedDate release];
		
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
	[d addObserver:self
		forKeyPath:@"trackList.isPlayed"
		   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
		   context:NULL];
	
	[self sizeTofitWidnow];
	[self play];
}

#pragma mark ### KVO & KVC ###
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
	if([keyPath isEqual:@"trackList.isPlayed"]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		
		if([new boolValue]) {
			[playButton setTitle:@"||"];
		} else {
			[playButton setTitle:@">"];
		}
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
	
	[self sizeTofitWidnow];
	
	[self play];
}
- (QTMovie *)qtMovie
{
	return qtMovie;
}

#pragma mark ### Other functions ###
- (void)sizeTofitWidnow
{
	id window = [self window];
	NSRect frame = [window frame];
	NSSize newSize = [self fitSizeToSize:frame.size];
	frame.origin.y += frame.size.height - newSize.height;
	frame.size = newSize;
	
	[window setFrame:frame display:YES animate:YES];
}
- (NSSize)fitSizeToSize:(NSSize)toSize
{
	QTMovie *curMovie = [self qtMovie];
	if(!curMovie) return toSize;
	
	NSSize qtViewSize = [qtView frame].size;
	NSSize currentWindowSize = [[self window] frame].size;
	
	// Area size without QTMovieView.
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
- (void)pause
{
	[qtView performSelectorOnMainThread:@selector(pause:) withObject:self waitUntilDone:NO];
}

- (void)enterFullScreen
{
	NSWindow *w = [self fullscreenWindow];
	
	nomalModeSavedFrame = [qtView frame];
	
	[[self window] orderOut:self];
	[w setContentView:qtView];
	
//	[NSMenu setMenuBarVisible:NO];
	SetSystemUIMode (kUIModeAllHidden, kUIOptionAutoShowMenuBar);
	
	[w makeKeyAndOrderFront:self];
	[w makeFirstResponder:qtView];	
}
- (void)exitFullScreen
{
	
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
	[[self window] makeFirstResponder:qtView];
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

#pragma mark ### Actions ###
- (IBAction)togglePlayAndPause:(id)sender
{
	if([[self valueForKeyPath:@"document.trackList.isPlayed"] boolValue]) {
		[self pause];
	} else {
		[self play];
	}
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
	if(fullScreenMode) {
		[self exitFullScreen];
		fullScreenMode = NO;
	} else {
		[self enterFullScreen];
		fullScreenMode = YES;
	}
}

- (IBAction)forwardTagValueSecends:(id)sender
{
	if(![sender respondsToSelector:@selector(tag)]) return;
	
	int tag = [sender tag];
	if(tag == 0) return;
	
	QTTime current = [[self qtMovie] currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime new = QTMakeTimeWithTimeInterval(cur + tag);
	[[self qtMovie] setCurrentTime:new];
}
- (IBAction)backwardTagValueSecends:(id)sender
{
	if(![sender respondsToSelector:@selector(tag)]) return;
	
	int tag = [sender tag];
	if(tag == 0) return;
	
	QTTime current = [[self qtMovie] currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime new = QTMakeTimeWithTimeInterval(cur - tag);
	[[self qtMovie] setCurrentTime:new];
}

#pragma mark ### Notification & Timer ###
- (void)didEndMovie:(id)notification
{
	[[[self document] trackList] next];
}
- (void)updateTimeIfNeeded:(id)timer
{
	QTMovie *qt = [self qtMovie];
	if(qt) {
		// force update time indicator.
		[qt willChangeValueForKey:@"currentTime"];
		[qt didChangeValueForKey:@"currentTime"];
	}
	
	// Hide cursor and controller, if mouse didn't move for 3 seconds.
	NSPoint mouse = [NSEvent mouseLocation];
	if(!NSEqualPoints(prevMouse, mouse)) {
		prevMouse = mouse;
		[prevMouseMovedDate autorelease];
		prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
	} else if(fullScreenMode && [prevMouseMovedDate timeIntervalSinceNow] < -3.0 ) {
		[NSCursor setHiddenUntilMouseMoves:YES];
		//
		// hide controller.
	}
}

#pragma mark ### NSResponder ###
- (void)cancelOperation:(id)sender
{
	if(fullScreenMode) {
		[self toggleFullScreenMode:self];
	}
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if([menuItem action] == @selector(toggleFullScreenMode:)) {
		if(fullScreenMode) {
			[menuItem setTitle:NSLocalizedString(@"Exit Full Screen", @"Exit Full Screen")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Full Screen", @"Full Screen")];
		}
		return YES;
	}
	
	return YES;
}

#pragma mark ### NSApplication Delegate ###
- (void)applicationWillTerminate:(NSNotification *)notification
{
	if(fullScreenMode) {
		[self toggleFullScreenMode:self];
	}
	[[self document] removeObserver:self forKeyPath:kCurrentIndexKeyPath];
	[[self document] removeObserver:self forKeyPath:@"trackList.isPlayed"];
}

#pragma mark ### NSWindow Delegate ###
- (BOOL)windowShouldClose:(id)sender
{
	[qtView pause:self];
	[self setQtMovie:nil];
	
	[[self document] removeObserver:self forKeyPath:kCurrentIndexKeyPath];
	[[self document] removeObserver:self forKeyPath:@"trackList.isPlayed"];
	[self setShouldCloseDocument:YES];
	
	[updateTime release];
	updateTime = nil;
	
	return YES;
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
	return [self fitSizeToSize:frameSize];
}
- (void)windowDidMove:(NSNotification *)notification
{
	if(fullscreenWindow && [notification object] == fullscreenWindow) {
		NSRect r = [fullscreenWindow frame];
		if(!NSEqualRects(r, NSZeroRect)) {
			[fullscreenWindow setFrameOrigin:NSZeroPoint];
		}
	}
}
@end
