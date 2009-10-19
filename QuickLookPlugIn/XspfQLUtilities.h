/*
 *  XspfQLUtilities.h
 *  XspfQT
 *
 *  Created by Hori, Masaki on 09/10/12.
 *  Copyright 2009 masakih. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>

@class QTMovie;
@class XspfQTComponent;
@class NSDate;

QTMovie *firstMovie(CFURLRef url);

XspfQTComponent *thumnailTrack(CFURLRef url, NSDate **thumnailTime);
CGImageRef thumnailForTrackTime(XspfQTComponent *track, NSDate *time, CGSize size);

NSSize maxSizeForFrame(NSSize size, CGSize frame);
