/*
 *  XspfQLUtilities.h
 *  XspfQT
 *
 *  Created by Hori, Masaki on 09/10/12.
 *  Copyright 2009 masakih. All rights reserved.
 *
 */

#import <CoreFoundation/CoreFoundation.h>

@class QTMovie;
@class NSURL;

QTMovie *firstMovie(CFURLRef url);
NSURL *firstMovieURL(CFURLRef url);
