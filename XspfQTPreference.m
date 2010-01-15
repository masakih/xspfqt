//
//  XspfQTPreference.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTPreference.h"

XspfQTPreference *XspfQTPref = nil;

static const CGFloat beginingPreloadPercentPreset = 0.85;

static NSString *BeginningPreloadPercentKey = @"beginingPreloadPercent";
static NSString *EnablePreloadingKey = @"EnablePreloading";

@implementation XspfQTPreference
static XspfQTPreference *sharedInstance = nil;

+ (XspfQTPreference *)sharedInstance
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
			XspfQTPref = sharedInstance;
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

- (NSUInteger)retainCount
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
	self = [super init];
	
	id ud = [NSUserDefaults standardUserDefaults];
	if([ud doubleForKey:BeginningPreloadPercentKey] == 0.0) {
		[ud setDouble:beginingPreloadPercentPreset forKey:BeginningPreloadPercentKey];
	}
	
	id dController = [NSUserDefaultsController sharedUserDefaultsController];
	[self bind:BeginningPreloadPercentKey
	  toObject:dController
   withKeyPath:@"values.beginingPreloadPercent"
	   options:nil];
	
	return self;
}
- (void)dealloc
{
	[self unbind:BeginningPreloadPercentKey];
		
	[super dealloc];
}

- (BOOL)preloadingEnabled
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:EnablePreloadingKey];
}
- (CGFloat)beginingPreloadPercent
{
	if(beginingPreloadPercent == 0.0) {
		return beginingPreloadPercentPreset;
	}
	
	return beginingPreloadPercent;
}
- (void)setBeginingPreloadPercent:(CGFloat)newPercent
{
	if(newPercent <= 0 || newPercent >= 1) return;
	beginingPreloadPercent = newPercent;
}
@end
