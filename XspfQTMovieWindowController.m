//
//  XspfQTMovieWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2008-2010, masakih
 All rights reserved.
 
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に
 限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含
 めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表
 示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、
 コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、
 明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証
 も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューター
 も、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか
 厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する
 可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用
 サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定
 されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害につい
 て、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2008-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1, Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
 3, The names of its contributors may be used to endorse or promote
    products derived from this software without specific prior
    written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#import <Carbon/Carbon.h>

#import "XspfQTMovieWindowController.h"
#import "XspfQTDocument.h"
#import "HMXSPFComponent.h"
#import "XspfQTFullScreenWindow.h"
#import "XspfQTMovieWindow.h"


#pragma mark #### Global Variables ####
/********* Global variables *******/
NSString *XspfQTMovieDidStartNotification = @"XspfQTMovieDidStartNotification";
NSString *XspfQTMovieDidPauseNotification = @"XspfQTMovieDidPauseNotification";


@interface XspfQTMovieWindowController (Private)
- (NSSize)windowSizeWithoutQTView;
- (void)sizeTofitWidnow;
- (NSSize)fitSizeToSize:(NSSize)toSize;
- (NSWindow *)fullscreenWindow;
- (void)movieDidStart;
- (void)movieDidPause;

- (void)hideMenuBar;
- (void)showMenuBar;
@end
#ifndef MAC_OS_X_VERSION_10_6
@interface NSApplication (XspfQT)
typedef NSUInteger NSApplicationPresentationOptions;
- (NSApplicationPresentationOptions)presentationOptions;
- (void)setPresentationOptions:(NSApplicationPresentationOptions)newOptions;
enum {
    NSApplicationPresentationDefault                    = 0,
    NSApplicationPresentationAutoHideDock               = (1 <<  0),    // Dock appears when moused to
    NSApplicationPresentationHideDock                   = (1 <<  1),    // Dock is entirely unavailable
	
    NSApplicationPresentationAutoHideMenuBar            = (1 <<  2),    // Menu Bar appears when moused to
    NSApplicationPresentationHideMenuBar                = (1 <<  3),    // Menu Bar is entirely unavailable
	
    NSApplicationPresentationDisableAppleMenu           = (1 <<  4),    // all Apple menu items are disabled
    NSApplicationPresentationDisableProcessSwitching    = (1 <<  5),    // Cmd+Tab UI is disabled
    NSApplicationPresentationDisableForceQuit           = (1 <<  6),    // Cmd+Opt+Esc panel is disabled
    NSApplicationPresentationDisableSessionTermination  = (1 <<  7),    // PowerKey panel and Restart/Shut Down/Log Out disabled
    NSApplicationPresentationDisableHideApplication     = (1 <<  8),    // Application "Hide" menu item is disabled
    NSApplicationPresentationDisableMenuBarTransparency = (1 <<  9)     // Menu Bar's transparent appearance is disabled
};
@end
#endif

@implementation XspfQTMovieWindowController

#pragma mark ### Static variables ###
static const float sVolumeDelta = 0.1;
static const NSTimeInterval sUpdateTimeInterval = 0.5;
static NSString *const kQTMovieKeyPath = @"playingMovie";
static NSString *const kIsPlayedKeyPath = @"trackList.isPlayed";
static NSString *const kVolumeKeyPath = @"qtMovie.volume";

- (id)init
{
	self = [super initWithWindowNibName:@"XspfQTDocument"];
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[self setQtMovie:nil];
		
	[fullscreenWindow release];
	[self movieDidPause];
	[prevMouseMovedDate release];
	
	[super dealloc];
}
- (void)awakeFromNib
{
	prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
	[[self window] setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
	
	id doc = [self document];
	
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
	
	[[doc trackList] setSelectionIndex:0];
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
- (IBAction)showWindow:(id)sender
{
	if(!fullScreenMode) {
		[super showWindow:sender];
		return;
	}
}

#pragma mark ### KVO & KVC ###
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:kQTMovieKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		[self setQtMovie:new];
		return;
	}
	if([keyPath isEqualToString:kIsPlayedKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		if([new boolValue]) {
			[self movieDidStart];
		} else {
			[self movieDidPause];
		}
		return;
	}
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
		[nc addObserver:self selector:@selector(movieDidEndNotification:) name:QTMovieDidEndNotification object:qt];
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
// Area size without QTMovieView.
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
	if(fullScreenMode) return;
	
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
	NSRect newFrame = [[self window] frame];
	NSSize newSize;
	
	newSize = [self windowSizeWithoutQTView];
	newSize.width += movieSize.width;
	newSize.height += movieSize.height;
	
	newFrame.origin.y -= newSize.height - newFrame.size.height;	
	newFrame.size = newSize;
	
	NSWindow *w = [self window];
	[w setFrame:newFrame display:YES animate:YES];
}
- (void)movieDidStart
{
	[playButton setTitle:@"||"];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfQTMovieDidStartNotification object:self];
}
		
- (void)movieDidPause
{
	[playButton setTitle:@">"];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfQTMovieDidPauseNotification object:self];
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
	NSWindow *fullscreen = [self fullscreenWindow];
	
	normalModeSavedFrame = [qtView frame];
	
	XspfQTMovieWindow *player = (XspfQTMovieWindow *)[self window];
	
	[self hideMenuBar];
	
	NSRect newFrame = [qtView frame];
	newFrame.origin = [player convertBaseToScreen:newFrame.origin];
	newFrame.origin = [fullscreen convertScreenToBase:newFrame.origin];
	[qtView setFrame:newFrame];
	
	[[fullscreen contentView] addSubview:qtView];
	[fullscreen makeKeyAndOrderFront:self];
	[fullscreen makeFirstResponder:qtView];
	
	[[qtView animator] setFrame:[[NSScreen mainScreen] frame]];
		
	[self performSelector:@selector(resizeToFull:) withObject:nil afterDelay:0.1];
}
- (void)resizeToFull:(id)obj
{
		
	[[self window] orderOut:self];
	
	[fullscreenWindow makeKeyAndOrderFront:self];
}
- (void)exitFullScreen
{
	XspfQTMovieWindow *player = (XspfQTMovieWindow *)[self window];
	NSRect originalWFrame = [player frame];
	
	// calculate new Window frame.
	NSRect windowRect = originalWFrame;
	NSSize movieSize = [[[self qtMovie] attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width != 0) {		
		CGFloat newViewHeight =  normalModeSavedFrame.size.width * (movieSize.height / movieSize.width);
		
		windowRect.size.height = newViewHeight + windowSizeWithoutQTView.height;
		windowRect.origin.y -= windowRect.size.height - originalWFrame.size.height;
	}

	[player setFrame:windowRect display:NO];
	[player orderWindow:NSWindowBelow relativeTo:[fullscreenWindow windowNumber]];
	
	// move QTView.
	[qtView retain];
	{
		NSRect movieViewFrame = [[player contentView] frame];
		movieViewFrame.size.height -= [controllerView frame].size.height;
		movieViewFrame.origin.y = [controllerView frame].size.height;
		movieViewFrame.origin = [player convertBaseToScreen:movieViewFrame.origin];
		movieViewFrame.origin = [fullscreenWindow convertScreenToBase:movieViewFrame.origin];
		[[qtView animator] setFrame:movieViewFrame];
	}
	[qtView release];
		
	NSTimeInterval delay = [[NSAnimationContext currentContext] duration] + 0.07;
	NSLog(@"delay %f", delay);
	[self performSelector:@selector(resizeFullscreenWindow:) withObject:nil afterDelay:delay];
}
- (void)resizeFullscreenWindow:(id)obj
{	
	XspfQTMovieWindow *player = (XspfQTMovieWindow *)[self window];
	
	NSRect r = [qtView frame];
	r.origin.x = 0;
	r.origin.y = [controllerView frame].size.height;
	[qtView setFrame:r];
	[[player contentView] addSubview:qtView];
	[fullscreenWindow orderOut:self];
	
	[self showMenuBar];
	
	[player makeKeyAndOrderFront:self];
	[player makeFirstResponder:qtView];
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
	[fullscreenWindow setBackgroundColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
	[fullscreenWindow setDelegate:self];
	[fullscreenWindow setWindowController:self];
	[fullscreenWindow setOpaque:NO];
	
	if([fullscreenWindow respondsToSelector:@selector(setAnimationBehavior:)]) {
		[fullscreenWindow setAnimationBehavior:NSWindowAnimationBehaviorNone];
	}
	
	return fullscreenWindow;
}
- (void)hideMenuBar
{
	if(![NSApp respondsToSelector:@selector(setPresentationOptions:)]) {
		SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar);
		return;
	}
	
	NSApplicationPresentationOptions currentPresentation = [NSApp presentationOptions];
	[NSApp setPresentationOptions:
	 currentPresentation | (NSApplicationPresentationAutoHideDock | NSApplicationPresentationAutoHideMenuBar)];
}
- (void)showMenuBar
{
	if(![NSApp respondsToSelector:@selector(setPresentationOptions:)]) {
		[NSMenu setMenuBarVisible:YES];
		return;
	}
	
	NSApplicationPresentationOptions currentPresentation = [NSApp presentationOptions];
	[NSApp setPresentationOptions:
	 currentPresentation & ~(NSApplicationPresentationAutoHideDock | NSApplicationPresentationAutoHideMenuBar)];
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
- (IBAction)gotoBeginning:(id)sender
{
	[qtView gotoBeginning:sender];
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
	if([[self window] respondsToSelector:@selector(toggleFullScreen:)]) {
		[[self window] toggleFullScreen:self];
		return;
	}
	
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
- (IBAction)gotoBeginningOrPreviousTrack:(id)sender
{
	QTTime current = [[self qtMovie] currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime duration = [[self qtMovie] duration];
	NSTimeInterval dur;
	if(!QTGetTimeInterval(duration, &dur)) return;
	
	if(cur > (dur * 0.01)) {
		[self gotoBeginning:sender];
	} else {
		[self previousTrack:sender];
	}
}

- (IBAction)gotoThumbnailFrame:(id)sender
{
	HMXSPFComponent *trackList = [[self document] trackList];
	HMXSPFComponent *thumbnailTrack = [trackList thumbnailTrack];
	NSTimeInterval time = [trackList thumbnailTimeInterval];
	
	NSUInteger num = [trackList indexOfChild:thumbnailTrack];
	if(num == NSNotFound) return;
	
	[trackList setSelectionIndex:num];
	
	QTTime new = QTMakeTimeWithTimeInterval(time);
	[[self qtMovie] setCurrentTime:new];
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
	if(fullScreenMode) return;
	
	NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
	NSSize windowDecorationSize = [self windowSizeWithoutQTView];
	NSRect windowFrame = [[self window] frame];
	NSSize movieSize = windowFrame.size;
	NSSize newSize;
	
	movieSize.width -= windowDecorationSize.width;
	movieSize.height -= windowDecorationSize.height;
	screenSize.height -= windowDecorationSize.height;
	
	if(movieSize.height == 0) return;
	
	newSize.height = screenSize.height;
	newSize.width = newSize.height * (movieSize.width / movieSize.height);
	
	newSize.height += windowDecorationSize.height;
	newSize.width += windowDecorationSize.width;
	
	windowFrame.size = newSize;
	windowFrame.origin.y = [[NSScreen mainScreen] visibleFrame].origin.y;
	[[self window] setFrame:windowFrame display:YES animate:YES];
}

#pragma mark ### Notification & Timer ###
- (void)movieDidEndNotification:(id)notification
{
	[[[self document] trackList] next];
}

// call from XspfQTMovieTimer.
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
	SEL action = [menuItem action];
	if(action == @selector(toggleFullScreenMode:)) {
		if(fullScreenMode) {
			[menuItem setTitle:NSLocalizedString(@"Exit Full Screen", @"Exit Full Screen")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Full Screen", @"Full Screen")];
		}
		return YES;
	}
	
	if(action == @selector(gotoThumbnailFrame:)) {
		if(![[[self document] trackList] thumbnailTrack]) return NO;
	}
	
	if(action == @selector(normalSize:)
	   || action == @selector(halfSize:)
	   || action == @selector(doubleSize:)
	   || action == @selector(screenSize:)) {
		if(fullScreenMode) {
			return NO;
		} else {
			return YES;
		}
	}
	
	return YES;
}

#pragma mark ### XspfQTDocument Notification ###
- (void)documentWillClose:(NSNotification *)notification
{
	id doc = [notification object];
	
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
		
	return YES;
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
	if(fullScreenMode) return frameSize;
	if(isChangingFullScreen) return frameSize;
	
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
- (void)hideController:(id)sender
{
	for(NSView *view in [controllerView subviews]) {
		[view setHidden:YES];
	}
}
- (void)showController:(id)sender
{
	for(NSView *view in [controllerView subviews]) {
		[view setHidden:NO];
	}
}
- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
	fullScreenMode = YES;
	
	NSSize windowContentSize = [[[self window] contentView] frame].size;
	NSRect qtViewFrame = [qtView frame];
	qtViewFrame.size = windowContentSize;
	qtViewFrame.origin = NSZeroPoint;
	[qtView setFrame:qtViewFrame];
	
	[self hideController:nil];
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
	NSRect windowContentRect = [[[self window] contentView] frame];
	NSSize controllerSize= [controllerView frame].size;
	windowContentRect.size.height -= controllerSize.height;
	windowContentRect.origin.y = controllerSize.height;
	[qtView setFrame:windowContentRect];
	[self showController:nil];
	
	fullScreenMode = NO;
}
- (void)windowDidExitFullScreen:(NSNotification *)notification
{
	[self sizeTofitWidnow];
}


@end
