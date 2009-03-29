//
//  XspfQTPreference.h
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/29.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfQTPreference : NSObject
{
	CGFloat beginingPreloadPercent;
}

+ (XspfQTPreference *)sharedInstance;

- (BOOL)preloadingEnabled;
- (CGFloat)beginingPreloadPercent;
- (void)setBeginingPreloadPercent:(CGFloat)newPercent;

@end

extern XspfQTPreference *XspfQTPref;
