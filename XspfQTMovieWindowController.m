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
@end

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
	NSRect originalWFrame = [player frame];
	
	// calculate new Window frame.
	NSRect windowRect = originalWFrame;
	NSSize movieSize = [[[self qtMovie] attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
	if(movieSize.width != 0) {		
		CGFloat newViewHeight =  normalModeSavedFrame.size.width * (movieSize.height / movieSize.width);
		
		windowRect.size.height = newViewHeight + windowSizeWithoutQTView.height;
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
	
	// move QTView.
	[qtView retain];
	{
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
	if([menuItem action] == @selector(toggleFullScreenMode:)) {
		if(fullScreenMode) {
			[menuItem setTitle:NSLocalizedString(@"Exit Full Screen", @"Exit Full Screen")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"Full Screen", @"Full Screen")];
		}
		return YES;
	}
	
	if([menuItem action] == @selector(screenSize:)) {
		return NO;
	}
	
	if([menuItem action] == @selector(normalSize:)
	   || [menuItem action] == @selector(halfSize:)
	   || [menuItem action] == @selector(doubleSize:)) {
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
@end
