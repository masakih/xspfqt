//
//  XspfQTMovieTimer.h
//  XspfQT
//
//  Created by Hori, Masaki on 09/10/31.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "XspfQTDocument.h"
#import "XspfQTMovieWindowController.h"


@interface XspfQTMovieTimer : NSObject
{
	NSTimer *timer;
	NSMutableArray *documents;
	NSMutableDictionary *movieWindowControllers;
	
	NSMutableArray *pausedDocuments;
}

+ (id)movieTimer;

- (void)put:(XspfQTDocument *)doc;

@end
