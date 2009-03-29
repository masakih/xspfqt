//
//  XspfQTPreferenceWindowController.h
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/17.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfQTPreferenceWindowController : NSWindowController
{
	IBOutlet NSSlider *beginingPreloadPercentSlider;
}
+ (XspfQTPreferenceWindowController *)sharedInstance;
@end
