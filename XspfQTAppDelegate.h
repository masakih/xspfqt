//
//  XspfQTAppDelegate.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfQTAppDelegate : NSObject
{
	NSWindow *mainWindowStore;
//	CGFloat beginingPreloadPercent;
}

//- (BOOL)preloadingEnabled;
//- (CGFloat)beginingPreloadPercent;
//- (void)setBeginingPreloadPercent:(CGFloat)newPercent;

- (IBAction)openInformationPanel:(id)sender;
- (IBAction)showPreferenceWindow:(id)sender;
- (IBAction)playedTrack:(id)sender;
@end

//extern XspfQTAppDelegate *XspfQTApp;
