//
//  XspfQTAppDelegate.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTAppDelegate.h"
#import "XspfQTValueTransformers.h"
#import "XspfQTInformationWindowController.h"

@implementation XspfQTAppDelegate

+ (void)initialize
{
	[NSValueTransformer setValueTransformer:[[[XspfQTTimeTransformer alloc] init] autorelease]
									forName:@"XspfQTTimeTransformer"];
	[NSValueTransformer setValueTransformer:[[[XspfQTTimeDateTransformer alloc] init] autorelease]
									forName:@"XspfQTTimeDateTransformer"];
	[NSValueTransformer setValueTransformer:[[[XspfQTSizeToStringTransformer alloc] init] autorelease]
									forName:@"XspfQTSizeToStringTransformer"];
	[NSValueTransformer setValueTransformer:[[[XspfQTFileSizeStringTransformer alloc] init] autorelease]
									forName:@"XspfQTFileSizeStringTransformer"];
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
- (IBAction)togglePlayAndPause:(id)sender
{
	[[mainWindowStore windowController] togglePlayAndPause:sender];
}
- (IBAction)nextTrack:(id)sender
{
	[[mainWindowStore windowController] nextTrack:sender];
}
- (IBAction)previousTrack:(id)sender
{
	[[mainWindowStore windowController] previousTrack:sender];
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if([menuItem action] == @selector(openInformationPanel:)) {
		return YES;
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
