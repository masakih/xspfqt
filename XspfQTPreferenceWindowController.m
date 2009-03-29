//
//  XspfQTPreferenceWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/17.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTPreferenceWindowController.h"


@implementation XspfQTPreferenceWindowController
static XspfQTPreferenceWindowController *sharedInstance = nil;

+ (XspfQTPreferenceWindowController *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark-

- (id)init
{
	[super initWithWindowNibName:@"XspfQTPreference"];
	return self;
}

- (void)awakeFromNib
{
	[beginingPreloadPercentSlider setMinValue:0.01];
	[beginingPreloadPercentSlider setMaxValue:0.99];
	[beginingPreloadPercentSlider setAltIncrementValue:0.05];
}
@end
