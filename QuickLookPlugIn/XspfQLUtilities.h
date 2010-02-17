/*
 *  XspfQLUtilities.h
 *  XspfQT
 *
 *  Created by Hori, Masaki on 09/10/12.
 *  Copyright 2009 masakih. All rights reserved.
 *
 */

#include <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>

@class QTMovie;
@class HMXSPFComponent;

QTMovie *firstMovie(CFURLRef url);

HMXSPFComponent *thumbnailTrack(CFURLRef url, NSTimeInterval *thumbnailTime);
CGImageRef thumbnailForTrackTime(QLThumbnailRequestRef thumbnail, HMXSPFComponent *track, NSTimeInterval time, CGSize size);

NSSize maxSizeForFrame(NSSize size, CGSize frame);
