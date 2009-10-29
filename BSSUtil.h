/*
 *  BSSUtil.h
 *  BSSpotlighter
 *
 *  Created by Hori,Masaki on 06/12/16.
 *  Copyright 2006 masakih. All rights reserved.
 *
 */

#import "stdarg.h"
#import <CoreServices/CoreServices.h>

@class NSString;

void BSSLog(NSString *format, ...);
void BSSLogv(NSString *format, va_list args);

extern NSString *BSSLogForceWrite;

enum {
	kBSSUtilNotFoundFinderPSNErr = -10000,
	kBSSUtilCanNotCreateTragetDescErr = -10001,
	kBSSUtilCanNotCreateAppleEventErr = -10002,
};

OSStatus openInFinderWithPath(NSString *fullpath);
OSStatus openInfomationInFinderWithPath(NSString *fullpath);
