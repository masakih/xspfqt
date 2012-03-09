//
//  XspfQTMovieWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
<<<<<<< HEAD:XspfQTMovieWindowController.m
//  Copyright 2008 masakih. All rights reserved.
//

=======
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2008-2010,2012, masakih
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
 Copyright (c) 2008-2010,2012, masakih
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

>>>>>>> trunk:XspfQTMovieWindowController.m
#import <Carbon/Carbon.h>

#import "XspfQTMovieWindowController.h"
#import "XspfQTDocument.h"
<<<<<<< HEAD:XspfQTMovieWindowController.m
#import "XspfQTComponent.h"
=======
#import "HMXSPFComponent.h"
>>>>>>> trunk:XspfQTMovieWindowController.m
#import "XspfQTFullScreenWindow.h"
#import "XspfQTMovieWindow.h"


#pragma mark #### Global Variables ####
/********* Global variables *******/
NSString *XspfQTMovieDidStartNotification = @"XspfQTMovieDidStartNotification";
NSString *XspfQTMovieDidPauseNotification = @"XspfQTMovieDidPauseNotification";

<<<<<<< HEAD:XspfQTMovieWindowController.m
=======
@interface XspfQTMovieWindowController()
@property BOOL fullScreenMode;

@property (readonly) XspfQTDocument *qtDocument;
@property (readonly) XspfQTMovieWindow *qtWindow;
@end
>>>>>>> trunk:XspfQTMovieWindowController.m

@interface XspfQTMovieWindowController (Private)
- (NSSize)windowSizeWithoutQTView;
- (void)sizeTofitWidnow;
- (NSSize)fitSizeToSize:(NSSize)toSize;
- (NSWindow *)fullscreenWindow;
- (void)movieDidStart;
- (void)movieDidPause;
<<<<<<< HEAD:XspfQTMovieWindowController.m
@end

@implementation XspfQTMovieWindowController
=======

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
@synthesize qtMovie = _qtMovie;
@synthesize fullScreenMode = _fullScreenMode;
>>>>>>> trunk:XspfQTMovieWindowController.m

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
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[self setQtMovie:nil];
=======
	self.qtMovie = nil;
>>>>>>> trunk:XspfQTMovieWindowController.m
		
	[fullscreenWindow release];
	[self movieDidPause];
	[prevMouseMovedDate release];
	
	[super dealloc];
}
- (void)awakeFromNib
{
	prevMouseMovedDate = [[NSDate dateWithTimeIntervalSinceNow:0.0] retain];
<<<<<<< HEAD:XspfQTMovieWindowController.m
	
	id doc = [self document];
=======
	[[self window] setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
	
	XspfQTDocument *doc = self.qtDocument;
>>>>>>> trunk:XspfQTMovieWindowController.m
	
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
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[[doc trackList] setSelectionIndex:0];
=======
	doc.trackList.selectionIndex = 0;
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
=======
- (IBAction)showWindow:(id)sender
{
	if(!self.fullScreenMode) {
		[super showWindow:sender];
		return;
	}
}
>>>>>>> trunk:XspfQTMovieWindowController.m

#pragma mark ### KVO & KVC ###
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:kQTMovieKeyPath]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
<<<<<<< HEAD:XspfQTMovieWindowController.m
		[self setQtMovie:new];
=======
		self.qtMovie = new;
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(qtMovie == qt) return;
	if([qtMovie isEqual:qt]) return;
=======
	if(_qtMovie == qt) return;
	if([_qtMovie isEqual:qt]) return;
>>>>>>> trunk:XspfQTMovieWindowController.m
	if(qt == (id)[NSNull null]) qt = nil;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(qtMovie) {
		[nc removeObserver:self name:nil object:qtMovie];
=======
	if(_qtMovie) {
		[nc removeObserver:self name:nil object:_qtMovie];
>>>>>>> trunk:XspfQTMovieWindowController.m
	}
	if(qt) {
		[nc addObserver:self selector:@selector(movieDidEndNotification:) name:QTMovieDidEndNotification object:qt];
	}
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(qtMovie) {
		[qt setVolume:[qtMovie volume]];
		[qt setMuted:[qtMovie muted]];
	}
	[qtMovie autorelease];
	qtMovie = [qt retain];
	
	if(!qtMovie) return;
=======
	if(_qtMovie) {
		[qt setVolume:[_qtMovie volume]];
		[qt setMuted:[_qtMovie muted]];
	}
	[_qtMovie autorelease];
	_qtMovie = [qt retain];
	
	if(!_qtMovie) return;
>>>>>>> trunk:XspfQTMovieWindowController.m
	
	[self synchronizeWindowTitleWithDocumentName];
	[self sizeTofitWidnow];
	[self play];
}
- (QTMovie *)qtMovie
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	return qtMovie;
=======
	return _qtMovie;
}
- (XspfQTDocument *)qtDocument
{
	return (XspfQTDocument *)self.document;
}
- (XspfQTMovieWindow *)qtWindow
{
	return (XspfQTMovieWindow *)self.window;
>>>>>>> trunk:XspfQTMovieWindowController.m
}

#pragma mark ### Other functions ###
// Area size without QTMovieView.
- (NSSize)windowSizeWithoutQTView
{
	if(windowSizeWithoutQTView.width == 0
	   && windowSizeWithoutQTView.height == 0) {
<<<<<<< HEAD:XspfQTMovieWindowController.m
		QTMovie *curMovie = [self qtMovie];
		if(!curMovie) return windowSizeWithoutQTView;
		
		NSSize qtViewSize = [qtView frame].size;
		NSSize currentWindowSize = [[self window] frame].size;
=======
		QTMovie *curMovie = self.qtMovie;
		if(!curMovie) return windowSizeWithoutQTView;
		
		NSSize qtViewSize = [qtView frame].size;
		NSSize currentWindowSize = [self.window frame].size;
>>>>>>> trunk:XspfQTMovieWindowController.m
		
		windowSizeWithoutQTView = NSMakeSize(currentWindowSize.width - qtViewSize.width,
											 currentWindowSize.height - qtViewSize.height);
	}
	
	return windowSizeWithoutQTView;
}
- (void)sizeTofitWidnow
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	id window = [self window];
=======
	if(self.fullScreenMode) return;
	
	id window = self.window;
>>>>>>> trunk:XspfQTMovieWindowController.m
	NSRect frame = [window frame];
	NSSize newSize = [self fitSizeToSize:frame.size];
	frame.origin.y += frame.size.height - newSize.height;
	frame.size = newSize;
	
	[window setFrame:frame display:YES animate:YES];
}
- (NSSize)fitSizeToSize:(NSSize)toSize
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	QTMovie *curMovie = [self qtMovie];
=======
	QTMovie *curMovie = self.qtMovie;
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	NSRect newFrame = [[self window] frame];
=======
	NSRect newFrame = [self.window frame];
>>>>>>> trunk:XspfQTMovieWindowController.m
	NSSize newSize;
	
	newSize = [self windowSizeWithoutQTView];
	newSize.width += movieSize.width;
	newSize.height += movieSize.height;
	
	newFrame.origin.y -= newSize.height - newFrame.size.height;	
	newFrame.size = newSize;
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	NSWindow *w = [self window];
	[w setFrame:newFrame display:YES animate:YES];
=======
	[self.window setFrame:newFrame display:YES animate:YES];
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	NSWindow *w = [self fullscreenWindow];
	
	normalModeSavedFrame = [qtView frame];
	
	XspfQTMovieWindow *player = (XspfQTMovieWindow *)[self window];
	NSRect originalWFrame = [player frame];
	
	SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar);
	
	NSRect newWFrame = [[NSScreen mainScreen] frame];
	
	newWFrame.size.width += windowSizeWithoutQTView.width;
	newWFrame.size.height += windowSizeWithoutQTView.height;
	newWFrame.origin.y -= windowSizeWithoutQTView.height;
	
	isChangingFullScreen = YES;
	[player setIsChangingFullScreen:YES];
	
	[player setFrame:newWFrame display:YES animate:YES];
	
	[player setIsChangingFullScreen:NO];
	isChangingFullScreen = NO;
	
	[w setContentView:qtView];
	[w makeKeyAndOrderFront:self];
	
	[w makeFirstResponder:qtView];
	
	[player orderOut:self];
	[player setFrame:originalWFrame display:NO];
}
- (void)exitFullScreen
{
	XspfQTMovieWindow *player = (XspfQTMovieWindow *)[self window];
=======
	NSWindow *fullscreen = [self fullscreenWindow];
	
	normalModeSavedFrame = [qtView frame];
	
	XspfQTMovieWindow *player = self.qtWindow;
	
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
		
	[self.window orderOut:self];
	
	[fullscreenWindow makeKeyAndOrderFront:self];
}
- (void)exitFullScreen
{
	XspfQTMovieWindow *player = self.qtWindow;
>>>>>>> trunk:XspfQTMovieWindowController.m
	NSRect originalWFrame = [player frame];
	
	// calculate new Window frame.
	NSRect windowRect = originalWFrame;
<<<<<<< HEAD:XspfQTMovieWindowController.m
	NSSize movieSize = [[[self qtMovie] attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
=======
	NSSize movieSize = [[self.qtMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
>>>>>>> trunk:XspfQTMovieWindowController.m
	if(movieSize.width != 0) {		
		CGFloat newViewHeight =  normalModeSavedFrame.size.width * (movieSize.height / movieSize.width);
		
		windowRect.size.height = newViewHeight + windowSizeWithoutQTView.height;
<<<<<<< HEAD:XspfQTMovieWindowController.m
		windowRect.origin.y -= windowRect.size.height - originalWFrame.size.height + [player titlebarHeight];
	}
	
	isChangingFullScreen = YES;
	[player setIsChangingFullScreen:YES];
	
	// caluculate screen size window frame.
	NSRect screenWFrame = [[NSScreen mainScreen] frame];	
	screenWFrame.size.width += windowSizeWithoutQTView.width;
	screenWFrame.size.height += windowSizeWithoutQTView.height;
	screenWFrame.origin.y -= windowSizeWithoutQTView.height;
	[player setFrame:screenWFrame display:NO];
	
	isChangingFullScreen = NO;
=======
		windowRect.origin.y -= windowRect.size.height - originalWFrame.size.height;
	}

	[player setFrame:windowRect display:NO];
	[player orderWindow:NSWindowBelow relativeTo:[fullscreenWindow windowNumber]];
>>>>>>> trunk:XspfQTMovieWindowController.m
	
	// move QTView.
	[qtView retain];
	{
<<<<<<< HEAD:XspfQTMovieWindowController.m
//		[qtView removeFromSuperview];
		NSRect fViewRec = [qtView frame];
		
		// for do not flushing qtview.
		[fullscreenWindow setContentView:[[[NSView alloc] initWithFrame:fViewRec] autorelease]];
		
		fViewRec.origin.y += windowSizeWithoutQTView.height - [player titlebarHeight];
		[qtView setFrame:fViewRec];
		[[player contentView] addSubview:qtView];
	}
	[qtView release];
	
	[player makeKeyAndOrderFront:self];
	[player makeFirstResponder:qtView];
	
	[fullscreenWindow orderOut:self];
	
	[player setFrame:windowRect display:YES animate:YES];
	
	[NSMenu setMenuBarVisible:YES];
	[player setIsChangingFullScreen:NO];
=======
		NSRect movieViewFrame = [[player contentView] frame];
		movieViewFrame.size.height -= [controllerView frame].size.height;
		movieViewFrame.origin.y = [controllerView frame].size.height;
		movieViewFrame.origin = [player convertBaseToScreen:movieViewFrame.origin];
		movieViewFrame.origin = [fullscreenWindow convertScreenToBase:movieViewFrame.origin];
		[[qtView animator] setFrame:movieViewFrame];
	}
	[qtView release];
		
	NSTimeInterval delay = [[NSAnimationContext currentContext] duration] + 0.07;
	[self performSelector:@selector(resizeFullscreenWindow:) withObject:nil afterDelay:delay];
}
- (void)resizeFullscreenWindow:(id)obj
{	
	XspfQTMovieWindow *player = self.qtWindow;
	
	NSRect r = [qtView frame];
	r.origin.x = 0;
	r.origin.y = [controllerView frame].size.height;
	[qtView setFrame:r];
	[[player contentView] addSubview:qtView];
	[fullscreenWindow orderOut:self];
	
	[self showMenuBar];
	
	[player makeKeyAndOrderFront:self];
	[player makeFirstResponder:qtView];
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[fullscreenWindow setBackgroundColor:[NSColor blackColor]];
	[fullscreenWindow setDelegate:self];
	[fullscreenWindow setWindowController:self];
	
	return fullscreenWindow;
}

=======
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
>>>>>>> trunk:XspfQTMovieWindowController.m
#pragma mark ### Actions ###
- (IBAction)togglePlayAndPause:(id)sender
{
	if([[self valueForKeyPath:@"document.trackList.isPlayed"] boolValue]) {
		[self pause];
	} else {
		[self play];
	}
}
<<<<<<< HEAD:XspfQTMovieWindowController.m
=======
- (IBAction)gotoBeginning:(id)sender
{
	[qtView gotoBeginning:sender];
}
>>>>>>> trunk:XspfQTMovieWindowController.m

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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(fullScreenMode) {
		[self exitFullScreen];
		fullScreenMode = NO;
	} else {
		[self enterFullScreen];
		fullScreenMode = YES;
=======
	if([self.window respondsToSelector:@selector(toggleFullScreen:)]) {
		[self.window toggleFullScreen:self];
		return;
	}
	
	if(self.fullScreenMode) {
		[self exitFullScreen];
		self.fullScreenMode = NO;
	} else {
		[self enterFullScreen];
		self.fullScreenMode = YES;
>>>>>>> trunk:XspfQTMovieWindowController.m
	}
}

- (IBAction)forwardTagValueSecends:(id)sender
{
	if(![sender respondsToSelector:@selector(tag)]) return;
	
	int tag = [sender tag];
	if(tag == 0) return;
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	QTTime current = [[self qtMovie] currentTime];
=======
	QTTime current = [self.qtMovie currentTime];
>>>>>>> trunk:XspfQTMovieWindowController.m
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime new = QTMakeTimeWithTimeInterval(cur + tag);
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[[self qtMovie] setCurrentTime:new];
=======
	[self.qtMovie setCurrentTime:new];
>>>>>>> trunk:XspfQTMovieWindowController.m
}
- (IBAction)backwardTagValueSecends:(id)sender
{
	if(![sender respondsToSelector:@selector(tag)]) return;
	
	int tag = [sender tag];
	if(tag == 0) return;
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	QTTime current = [[self qtMovie] currentTime];
=======
	QTTime current = [self.qtMovie currentTime];
>>>>>>> trunk:XspfQTMovieWindowController.m
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime new = QTMakeTimeWithTimeInterval(cur - tag);
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[[self qtMovie] setCurrentTime:new];
=======
	[self.qtMovie setCurrentTime:new];
>>>>>>> trunk:XspfQTMovieWindowController.m
}
- (IBAction)nextTrack:(id)sender
{
	[qtView pause:sender];
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[[[self document] trackList] next];
=======
	[self.qtDocument.trackList next];
>>>>>>> trunk:XspfQTMovieWindowController.m
}
- (IBAction)previousTrack:(id)sender
{
	[qtView pause:sender];
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[[[self document] trackList] previous];
=======
	[self.qtDocument.trackList previous];
}
- (IBAction)gotoBeginningOrPreviousTrack:(id)sender
{
	QTTime current = [self.qtMovie currentTime];
	NSTimeInterval cur;
	if(!QTGetTimeInterval(current, &cur)) return;
	
	QTTime duration = [self.qtMovie duration];
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
	HMXSPFComponent *trackList = self.qtDocument.trackList;
	HMXSPFComponent *thumbnailTrack = trackList.thumbnailTrack;
	NSTimeInterval time = trackList.thumbnailTimeInterval;
	
	NSUInteger num = [trackList indexOfChild:thumbnailTrack];
	if(num == NSNotFound) return;
	
	trackList.selectionIndex = num;
	
	QTTime new = QTMakeTimeWithTimeInterval(time);
	[self.qtMovie setCurrentTime:new];
>>>>>>> trunk:XspfQTMovieWindowController.m
}

- (IBAction)normalSize:(id)sender
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(fullScreenMode) return;
	
	QTMovie *curMovie = [self qtMovie];
=======
	if(self.fullScreenMode) return;
	
	QTMovie *curMovie = self.qtMovie;
>>>>>>> trunk:XspfQTMovieWindowController.m
	if(!curMovie) return;
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return;
	
	[self setMovieSize:movieSize];
}
- (IBAction)halfSize:(id)sender
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(fullScreenMode) return;
	
	QTMovie *curMovie = [self qtMovie];
=======
	if(self.fullScreenMode) return;
	
	QTMovie *curMovie = self.qtMovie;
>>>>>>> trunk:XspfQTMovieWindowController.m
	if(!curMovie) return;
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return;
	
	movieSize.width *= 0.5;
	movieSize.height *= 0.5;
	
	[self setMovieSize:movieSize];
}
- (IBAction)doubleSize:(id)sender
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(fullScreenMode) return;
	
	QTMovie *curMovie = [self qtMovie];
=======
	if(self.fullScreenMode) return;
	
	QTMovie *curMovie = self.qtMovie;
>>>>>>> trunk:XspfQTMovieWindowController.m
	if(!curMovie) return;
	
	NSSize movieSize = [[curMovie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width == 0) return;
	
	movieSize.width *= 2;
	movieSize.height *= 2;
	
	[self setMovieSize:movieSize];
}
- (IBAction)screenSize:(id)sender
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	//
	//
=======
	if(self.fullScreenMode) return;
	
	NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
	NSSize windowDecorationSize = [self windowSizeWithoutQTView];
	NSRect windowFrame = [self.window frame];
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
	[self.window setFrame:windowFrame display:YES animate:YES];
>>>>>>> trunk:XspfQTMovieWindowController.m
}

#pragma mark ### Notification & Timer ###
- (void)movieDidEndNotification:(id)notification
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[[[self document] trackList] next];
=======
	[self.qtDocument.trackList next];
>>>>>>> trunk:XspfQTMovieWindowController.m
}

// call from XspfQTMovieTimer.
- (void)updateTimeIfNeeded:(id)timer
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	QTMovie *qt = [self qtMovie];
=======
	QTMovie *qt = self.qtMovie;
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	} else if(fullScreenMode && [prevMouseMovedDate timeIntervalSinceNow] < -3.0 ) {
=======
	} else if(self.fullScreenMode && [prevMouseMovedDate timeIntervalSinceNow] < -3.0 ) {
>>>>>>> trunk:XspfQTMovieWindowController.m
		[NSCursor setHiddenUntilMouseMoves:YES];
		//
		// hide controller.
	}
}

#pragma mark ### NSResponder ###
- (void)cancelOperation:(id)sender
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(fullScreenMode) {
=======
	if(self.fullScreenMode) {
>>>>>>> trunk:XspfQTMovieWindowController.m
		[self toggleFullScreenMode:self];
	}
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if([menuItem action] == @selector(toggleFullScreenMode:)) {
		if(fullScreenMode) {
=======
	SEL action = [menuItem action];
	if(action == @selector(toggleFullScreenMode:)) {
		if(self.fullScreenMode) {
>>>>>>> trunk:XspfQTMovieWindowController.m
			[menuItem setTitle:NSLocalizedString(@"Exit Full Screen", @"Exit Full Screen")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Full Screen", @"Full Screen")];
		}
		return YES;
	}
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if([menuItem action] == @selector(screenSize:)) {
		return NO;
	}
	
	if([menuItem action] == @selector(normalSize:)
	   || [menuItem action] == @selector(halfSize:)
	   || [menuItem action] == @selector(doubleSize:)) {
		if(fullScreenMode) {
=======
	if(action == @selector(gotoThumbnailFrame:)) {
		if(!self.qtDocument.trackList.thumbnailTrack) return NO;
	}
	
	if(action == @selector(normalSize:)
	   || action == @selector(halfSize:)
	   || action == @selector(doubleSize:)
	   || action == @selector(screenSize:)) {
		if(self.fullScreenMode) {
>>>>>>> trunk:XspfQTMovieWindowController.m
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
	
<<<<<<< HEAD:XspfQTMovieWindowController.m
	if(fullScreenMode) {
=======
	if(self.fullScreenMode) {
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
	[self setQtMovie:nil];
=======
	self.qtMovie = nil;
>>>>>>> trunk:XspfQTMovieWindowController.m
		
	return YES;
}
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
<<<<<<< HEAD:XspfQTMovieWindowController.m
=======
	if(self.fullScreenMode) return frameSize;
>>>>>>> trunk:XspfQTMovieWindowController.m
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
<<<<<<< HEAD:XspfQTMovieWindowController.m
=======
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
	self.fullScreenMode = YES;
	
	NSSize windowContentSize = [self.window.contentView frame].size;
	NSRect qtViewFrame = [qtView frame];
	qtViewFrame.size = windowContentSize;
	qtViewFrame.origin = NSZeroPoint;
	[qtView setFrame:qtViewFrame];
	
	[self hideController:nil];
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
	NSRect windowContentRect = [self.window.contentView frame];
	NSSize controllerSize= [controllerView frame].size;
	windowContentRect.size.height -= controllerSize.height;
	windowContentRect.origin.y = controllerSize.height;
	[qtView setFrame:windowContentRect];
	[self showController:nil];
	
	self.fullScreenMode = NO;
}
- (void)windowDidExitFullScreen:(NSNotification *)notification
{
	[self sizeTofitWidnow];
}


>>>>>>> trunk:XspfQTMovieWindowController.m
@end
