//
//  XspfQTAppDelegate.m
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

#import "XspfQTAppDelegate.h"

#import "XspfQTPreference.h"
#import "XspfQTValueTransformers.h"
#import "XspfQTInformationWindowController.h"
#import "XspfQTPreferenceWindowController.h"


#import "AppleRemote.h"
#import "MultiClickRemoteBehavior.h"


@implementation XspfQTAppDelegate
@synthesize remoteControl;


+ (void)initialize
{
	[XspfQTPreference sharedInstance];
}

- (void)awakeFromNib
{
	self.remoteControl = [[[AppleRemote alloc] initWithDelegate:self] autorelease];
	
	remoteBehavior = [MultiClickRemoteBehavior new];		
	[remoteBehavior setDelegate:self];
	[remoteControl setDelegate:remoteBehavior];
//	[remoteBehavior setClickCountingEnabled:YES];
	[remoteBehavior setClickCountEnabledButtons:kRemoteButtonLeft | kRemoteButtonRight];

	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(windowDidBecomeMain:)
			   name:NSWindowDidBecomeMainNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(windowWillClose:)
			   name:NSWindowWillCloseNotification
			 object:nil];
}
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	self.remoteControl = nil;
	[remoteBehavior autorelease];
	
	[super dealloc];
}

#pragma mark ### Actions ###
- (IBAction)playedTrack:(id)sender
{
	// do noting.
}
- (IBAction)openInformationPanel:(id)sender
{
	XspfQTInformationWindowController *wc;
	wc = [XspfQTInformationWindowController sharedInstance];
	[wc showWindow:sender];
}
- (IBAction)showPreferenceWindow:(id)sender
{
	XspfQTPreferenceWindowController *pw;
	pw = [XspfQTPreferenceWindowController sharedInstance];
	[pw showWindow:self];
}
- (IBAction)togglePlayAndPause:(id)sender
{
	id windowController = [mainWindowStore windowController];
	if(![windowController respondsToSelector:@selector(togglePlayAndPause:)]) return;
	[windowController togglePlayAndPause:sender];
}
- (IBAction)nextTrack:(id)sender
{
	id windowController = [mainWindowStore windowController];
	if(![windowController respondsToSelector:@selector(nextTrack:)]) return;
	[[mainWindowStore windowController] nextTrack:sender];
}
- (IBAction)previousTrack:(id)sender
{
	id windowController = [mainWindowStore windowController];
	if(![windowController respondsToSelector:@selector(previousTrack:)]) return;
	[[mainWindowStore windowController] previousTrack:sender];
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	id windowController = [mainWindowStore windowController];
	if(action == @selector(togglePlayAndPause:)) {
		if(![windowController respondsToSelector:@selector(togglePlayAndPause:)]) return NO;
	}
	if(action == @selector(nextTrack:)) {
		if(![windowController respondsToSelector:@selector(nextTrack:)]) return NO;
	}
	if(action == @selector(previousTrack:)) {
		if(![windowController respondsToSelector:@selector(previousTrack:)]) return NO;
	}
	if(action == @selector(showPreferenceWindow:)) return YES;
	
	if([menuItem tag] == 10000) {
		NSWindow *m = mainWindowStore;
		if(!m) {
			m = [NSApp mainWindow];
		}
		NSString *title = [m valueForKeyPath:@"windowController.document.trackList.currentTrack.title"];
		if(title) {
			[menuItem setTitle:[NSString stringWithFormat:@"%@ played", title]];
		} else {
			[menuItem setTitle:@"Played Track Title"];
		}
		return NO;
	}
	if(!mainWindowStore) {
		return NO;
	}
	
	return YES;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (void)storeMainWindow
{
	mainWindowStore = [NSApp mainWindow];
}
- (void)unsaveMainWindow
{
	mainWindowStore = nil;
}
- (void)applicationWillHide:(NSNotification *)notification
{
	[self storeMainWindow];
}
- (void)applicationWillResignActive:(NSNotification *)notification
{
	[self storeMainWindow];
	[remoteControl stopListening:self];
}
- (void)applicationWillBecomeActive:(NSNotification *)aNotification
{
	[remoteControl startListening:self];
}
- (void)applicationDidUnhide:(NSNotification *)notification
{
	[self unsaveMainWindow];
}
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[self unsaveMainWindow];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[self storeMainWindow];
}
- (void)windowWillClose:(NSNotification *)notification
{
	[self unsaveMainWindow];
} 


#pragma mark-
#pragma mark#### Apple Remote Control Wrapper ####

static NSInteger XSPFQTmoveValue= 10;
- (void)remoteButtonDown:(RemoteControlEventIdentifier)identifier clickCount:(unsigned int)clickCount
{
	SEL action = NULL;
	
	switch(identifier) {
		case kRemoteButtonPlus:
			action = @selector(turnUpVolume:);
			break;
		case kRemoteButtonMinus:
			action = @selector(turnDownVolume:);
			break;			
		case kRemoteButtonMenu:
			action = @selector(toggleFullScreenMode:);
			break;			
		case kRemoteButtonPlay:
			action = @selector(togglePlayAndPause:);
			break;			
		case kRemoteButtonRight:
			XSPFQTmoveValue = 10 * clickCount;
			action = @selector(forwardTagValueSecends:);
			break;			
		case kRemoteButtonLeft:
			XSPFQTmoveValue = 10 * clickCount;
			action = @selector(backwardTagValueSecends:);
			break;			
		case kRemoteButtonRight_Hold:
			action = @selector(nextTrack:);
			break;	
		case kRemoteButtonLeft_Hold:
			action = @selector(previousTrack:);
			break;			
		case kRemoteButtonPlus_Hold:
			action = NULL;
			break;				
		case kRemoteButtonMinus_Hold:
			action = NULL;
			break;				
		case kRemoteButtonPlay_Hold:
			action = NULL;
			break;			
		case kRemoteButtonMenu_Hold:
			action = @selector(showHidePlayList:);
			break;
		case kRemoteControl_Switched:
			action = NULL;
			break;
		default:
			NSLog(@"Unmapped event for button %d", identifier);
			break;
	}
	
	if(!action) return;
	
	[NSApp sendAction:action to:nil from:self];
}
- (NSInteger)tag
{
	return XSPFQTmoveValue;
}
- (void)remoteButton:(RemoteControlEventIdentifier)identifier pressedDown:(BOOL)pressedDown clickCount:(unsigned int)clickCount
{
	if(pressedDown) {
		[self remoteButtonDown:identifier clickCount:clickCount];
	}
}
@end
