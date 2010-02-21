//
//  XspfQTAppDelegate.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTAppDelegate.h"

#import "XspfQTPreference.h"
#import "XspfQTValueTransformers.h"
#import "XspfQTInformationWindowController.h"
#import "XspfQTPreferenceWindowController.h"


@implementation XspfQTAppDelegate

+ (void)initialize
{
	[XspfQTPreference sharedInstance];
}

- (void)awakeFromNib
{
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
	id windowController = [mainWindowStore windowController];
	if([menuItem action] == @selector(togglePlayAndPause:)) {
		if(![windowController respondsToSelector:@selector(togglePlayAndPause:)]) return NO;
	}
	if([menuItem action] == @selector(nextTrack:)) {
		if(![windowController respondsToSelector:@selector(nextTrack:)]) return NO;
	}
	if([menuItem action] == @selector(previousTrack:)) {
		if(![windowController respondsToSelector:@selector(previousTrack:)]) return NO;
	}
	
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

@end
