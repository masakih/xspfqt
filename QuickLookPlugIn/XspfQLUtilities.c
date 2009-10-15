/*
 *  XspfQLUtilities.c
 *  XspfQT
 *
 *  Created by Hori, Masaki on 09/10/12.
 *  Copyright 2009 masakih. All rights reserved.
 *
 */

#include "XspfQLUtilities.h"

#import <QTKit/QTKit.h>

#import "XspfQTDocument.h"
#import "XspfQTComponent.h"

#if 1
static QTMovie *loadFromMovieURL(NSURL *url)
{
	QTMovie *result = nil;
	NSError *error = nil;
	
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   url, QTMovieURLAttribute,
						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
						   nil];
	result = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	if (result == nil) {
        if (error != nil) {
            NSLog(@"Couldn't load movie URL, error = %@", error);
        }
    }
	
	return [result autorelease];
}
#else
static QTMovie *loadFromMovieURL(NSURL *url)
{
	QTMovie *result = nil;
	NSError *error = nil;
	
	result = [QTMovie movieWithURL:url error:&error];
	if (result == nil) {
        if (error != nil) {
            NSLog(@"Couldn't load movie URL, error = %@", error);
        }
    }
	
	return result;
}
#endif

QTMovie *firstMovie(CFURLRef url)
{
	QTMovie *result = nil;
	NSError *theErr = nil;
		
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithContentsOfURL:(NSURL *)url
															 options:0
															   error:&theErr] autorelease];
	if(!d) {
		if(theErr) {
			NSLog(@"%@", theErr);
		}
		goto fail;
	}
	NSXMLElement *root = [d rootElement];
	id pl = [XspfQTComponent xspfComponemtWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create XspfQTComponent.");
		goto fail;
	} else {
		//		NSLog(@"DUMP ->%@", pl);
	}
	id trackList = [pl childAtIndex:0];
	[trackList setSelectionIndex:0];
	NSURL *movieURL = [trackList movieLocation];
	if(!movieURL) {
		NSLog(@"Can not get movie URL.");
		goto fail;
	}
	
    result = loadFromMovieURL(movieURL);
	
fail:
	return result;
}
