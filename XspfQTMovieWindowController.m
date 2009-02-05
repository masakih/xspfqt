//
//  XspfQTMovieWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTMovieWindowController.h"
#import "XspfQTDocument.h"
#import "XspfQTComponent.h"
#import "XspfQTFullScreenWindow.h"


@interface XspfQTMovieWindowController (Private)
- (NSSize)windowSizeWithoutQTView;
- (void)sizeTofitWidnow;
- (NSSize)fitSizeToSize:(NSSize)toSize;
- (NSWindow *)fullscreenWindow;
- (void)startedMovie;
- (void)stopedMovie;
@end

@implementation XspfQTMovieWindowController

#pragma mark ### Static variables ###
static const float sVolumeDelta = 0.1;
static const NSTimeInterval sUpdateTimeInterval = 0.01;
static NSString *const kQTMovieKeyPath = @"trackList.qtMovie";
static NSString *const kIsPlayedKeyPath = @"trackList.isPlayed";
static NSString *const kVolumeKeyPath = @"qtMovie.volume";

- (id)init
{
	if(self = [super initWithWindowNibName:@"XspfQTDocument"]) {
//		updateTime = [NSTimer scheduledTimerWithTimeInterval:sUpdateTimeInterval
//													  target:self
//													selector:@selector(updateTimeIfNeeded:)
//													userInfo:NULL
//													 repeats:YES];
	}
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setQtMovie:nil];
		
	[fullscreenWindow release];
	[self stopedMovie];
	[prevMouseMovedDate release];
	
	[super dealloc];
}
- (void)awakeFromNib
{
	prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
	
	id doc = [self document];
//	NSLog(@"Add Observed! %@", doc);
	[doc addObserver:self
		  forKeyPath:kQTMovieKeyPath
			 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			 context:NULL];
	[doc addObserver:self
		  forKeyPath:kIsPlayedKeyPath
			 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
			 context:NULL];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(documentWillClose:)
			   name:XspfQTDocumentWillCloseNotification
			 object:doc];
	
	[self setValue:[NSNumber numberWithInt:0]
		forKeyPath:@"document.trackList.selectionIndex"];
	[self sizeTofitWidnow];
	[self play];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	id title1 = [self valueForKeyPath:@"document.trackList.title"];
	id title2 = [self valueForKeyPath:@"document.trackList.currentTrack.title"];
	if(title1 && title2) {
		return [NSString stringWithFormat:@"%@ - %@",
				title1, title2];
	}
	if(title2) {
		return [NSString stringWithFormat:@"%@ - %@",
				displayName, title2];
	}
	return displayName;
}

#pragma mark ### KVO & KVC ###
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
//	NSLog(@"Observed!");
	if([keyPath isEqualToString:kQTMovieKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		[self setQtMovie:new];
		return;
	}
	if([keyPath isEqualToString:kIsPlayedKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
//		NSLog(@"Observed!");
		if([new boolValue]) {
			[self startedMovie];
		} else {
			[self stopedMovie];
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
	if(qt == (id)[NSNull null]) qt = nil;
	
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
	
	if(!qtMovie) return;
	
	[self synchronizeWindowTitleWithDocumentName];
	[self sizeTofitWidnow];
	[self play];
}
- (QTMovie *)qtMovie
{
	return qtMovie;
}

#pragma mark ### Other functions ###
- (NSSize)windowSizeWithoutQTView
{
	if(windowSizeWithoutQTView.width == 0
	   && windowSizeWithoutQTView.height == 0) {
		QTMovie *curMovie = [self qtMovie];
		if(!curMovie) return windowSizeWithoutQTView;
		
		NSSize qtViewSize = [qtView frame].size;
		NSSize currentWindowSize = [[self window] frame].size;
		
		windowSizeWithoutQTView = NSMakeSize(currentWindowSize.width - qtViewSize.width,
											 currentWindowSize.height - qtViewSize.height);
	}
	
	return windowSizeWithoutQTView;
}
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
	
	// Area size without QTMovieView.
	NSSize delta = [self windowSizeWithoutQTView];
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return toSize;
	
	float targetViewWidth = toSize.width - delta.width;
	float targetViewHeight = targetViewWidth * (movieSize.height / movieSize.width);
	
	targetViewWidth += delta.width;
	targetViewHeight += delta.height;
	
	return NSMakeSize(targetViewWidth, targetViewHeight);
}

- (NSSize)windowSizeFromMovieSize:(NSSize)movieSize
{
	
	//
	
	return NSZeroSize;
}

- (void)setMovieSize:(NSSize)movieSize
{
	//
}
- (void)startedMovie
{
	[playButton setTitle:@"||"];
	
	@synchronized(self) {
		if(updateTime) return;
		
		updateTime = [[NSTimer timerWithTimeInterval:sUpdateTimeInterval
											  target:self
											selector:@selector(updateTimeIfNeeded:)
											userInfo:NULL
											 repeats:YES] retain];
		
		NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
		[currentLoop addTimer:updateTime forMode:NSDefaultRunLoopMode];
	}
}
		
- (void)stopedMovie
{
	[playButton setTitle:@">"];
	
	@synchronized(self) {
		[updateTime invalidate];
		[updateTime release];
		updateTime = nil;
	}
}
- (void)play
{
	[qtView performSelectorOnMainThread:@selector(play:) withObject:self waitUntilDone:NO];
}
- (void)pause
{
	[qtView performSelectorOnMainThread:@selector(pause:) withObject:self waitUntilDone:NO];
}
- (void)stop
{
	[qtView performSelectorOnMainThread:@selector(pause:) withObject:self waitUntilDone:YES];
}
- (void)enterFullScreen
{
	NSWindow *w = [self fullscreenWindow];
	
	nomalModeSavedFrame = [qtView frame];
	
	[[self window] orderOut:self];
	[w setContentView:qtView];
	
//	[NSMenu setMenuBarVisible:NO];
	SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar);
	
	[w makeKeyAndOrderFront:self];
	[w makeFirstResponder:qtView];	
}
- (void)exitFullScreen
{
	[qtView retain];
	{
		[qtView removeFromSuperview];
		[qtView setFrame:nomalModeSavedFrame];
		[[[self window] contentView] addSubview:qtView];
	}
	[qtView release];
	
	[self sizeTofitWidnow];
	NSSize movieSize = [[[self qtMovie] attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width != 0) {
		NSRect windowRect = [[self window] frame];
		
		CGFloat contentViewHeight = [[[self window] contentView] frame].size.height;
		NSRect newViewRect = nomalModeSavedFrame;
		newViewRect.size.height = newViewRect.size.width * (movieSize.height / movieSize.width);
		newViewRect.origin.y = contentViewHeight - newViewRect.size.height;
		
		NSSize delta = [self windowSizeWithoutQTView];
		windowRect.size.height = newViewRect.size.height + delta.height;
		[[self window] setFrame:windowRect display:NO];
		
		[qtView setFrame:newViewRect];
	}
	
	[NSMenu setMenuBarVisible:YES];
	[[self fullscreenWindow] orderOut:self];
	
	[[self window] makeKeyAndOrderFront:self];
	[[self window] makeFirstResponder:qtView];
}

- (NSWindow *)fullscreenWindow
{
	if(fullscreenWindow) return fullscreenWindow;
	
	NSRect mainScreenRect = [[NSScreen mainScreen] frame];
	fullscreenWindow = [[XspfQTFullScreenWindow alloc] initWithContentRect:mainScreenRect
																 styleMask:NSBorderlessWindowMask
																   backing:NSBackingStoreBuffered
																	 defer:YES];
	[fullscreenWindow setReleasedWhenClosed:NO];
	[fullscreenWindow setBackgroundColor:[NSColor blackColor]];
	[fullscreenWindow setDelegate:self];
	[fullscreenWindow setWindowController:self];
	
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
	NSNumber *cv = [self valueForKeyPath:kVolumeKeyPath];
	cv = [NSNumber numberWithFloat:[cv floatValue] + sVolumeDelta];
	[self setValue:cv forKeyPath:kVolumeKeyPath];
}
- (IBAction)turnDownVolume:(id)sender
{
	NSNumber *cv = [self valueForKeyPath:kVolumeKeyPath];
	cv = [NSNumber numberWithFloat:[cv floatValue] - sVolumeDelta];
	[self setValue:cv forKeyPath:kVolumeKeyPath];
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
- (IBAction)nextTrack:(id)sender
{
	[qtView pause:sender];
	[[[self document] trackList] next];
}
- (IBAction)previousTrack:(id)sender
{
	[qtView pause:sender];
	[[[self document] trackList] previous];
}

- (IBAction)normalSize:(id)sender
{
	if(fullScreenMode) return;
	
	QTMovie *curMovie = [self qtMovie];
	if(!curMovie) return;
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return;
	
	[self setMovieSize:movieSize];
}
- (IBAction)halfSize:(id)sender
{
	if(fullScreenMode) return;
	
	QTMovie *curMovie = [self qtMovie];
	if(!curMovie) return;
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return;
	
	movieSize.width *= 0.5;
	movieSize.height *= 0.5;
	
	[self setMovieSize:movieSize];
}
- (IBAction)doubleSize:(id)sender
{
	if(fullScreenMode) return;
	
	QTMovie *curMovie = [self qtMovie];
	if(!curMovie) return;
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return;
	
	movieSize.width *= 2;
	movieSize.height *= 2;
	
	[self setMovieSize:movieSize];
}
- (IBAction)screenSize:(id)sender
{
	//
	//
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

#pragma mark ### XspfQTDocument Notification ###
- (void)documentWillClose:(NSNotification *)notification
{
	id doc = [notification object];
//	NSLog(@"Remove Observed! %@", doc);
	if(fullScreenMode) {
		[self toggleFullScreenMode:self];
	}
	
	[doc removeObserver:self forKeyPath:kQTMovieKeyPath];
	[doc removeObserver:self forKeyPath:kIsPlayedKeyPath];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:XspfQTDocumentWillCloseNotification object:doc];
}

#pragma mark ### NSWindow Delegate ###
- (BOOL)windowShouldClose:(id)sender
{
	[qtView pause:self];
	[self setQtMovie:nil];
	
	[updateTime invalidate];
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
		if(!NSEqualPoints(r.origin, NSZeroPoint)) {
			[fullscreenWindow setFrameOrigin:NSZeroPoint];
		}
	}
}
@end
