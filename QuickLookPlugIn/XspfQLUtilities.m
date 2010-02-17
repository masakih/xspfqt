/*
 *  XspfQLUtilities.c
 *  XspfQT
 *
 *  Created by Hori, Masaki on 09/10/12.
 *  Copyright 2009 masakih. All rights reserved.
 *
 */

#import "XspfQLUtilities.h"

#import <QTKit/QTKit.h>

#import "XspfQTDocument.h"
#import "HMXSPFComponent.h"
#import "XspfQTValueTransformers.h"

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

HMXSPFComponent *componentForURL(CFURLRef url)
{
	NSError *theErr = nil;
	
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithContentsOfURL:(NSURL *)url
															 options:0
															   error:&theErr] autorelease];
	if(!d) {
		if(theErr) {
			NSLog(@"%@", theErr);
		}
		return nil;
	}
	NSXMLElement *root = [d rootElement];
	HMXSPFComponent *pl = [HMXSPFComponent xspfComponemtWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create HMXSPFComponent.");
		return nil;
	}
	
	return pl;
}

QTMovie *firstMovie(CFURLRef url)
{
	QTMovie *result = nil;
	
	HMXSPFComponent *pl = componentForURL(url);

	HMXSPFComponent *trackList = [pl childAtIndex:0];
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

NSSize maxSizeForFrame(NSSize size, CGSize frame)
{
	NSSize result = size;
	CGFloat aspectRetio = size.width / size.height;
	CGFloat frameAspectRetio = frame.width / frame.height;
	
	if(aspectRetio > frameAspectRetio) {
		result.width = frame.width;
		result.height = result.width / aspectRetio;
	} else {
		result.height = frame.height;
		result.width = result.height * aspectRetio;
	}
	
	return result;
}

HMXSPFComponent *thumbnailTrack(CFURLRef url, NSTimeInterval *thumbnailTime)
{
	HMXSPFComponent *component = componentForURL(url);
	
	HMXSPFComponent *result = [component thumbnailTrack];
	NSTimeInterval ti = [component thumbnailTimeInterval];
	*thumbnailTime = ti;
	return result;
}
CGImageRef thumbnailForTrackTime(QLThumbnailRequestRef thumbnail, HMXSPFComponent *track, NSTimeInterval time, CGSize size)
{
	NSError *theErr = nil;
	QTMovie *movie = loadFromMovieURL([track movieLocation]);
	if(QLThumbnailRequestIsCancelled(thumbnail)) {
		return NULL;
	}
	
	NSValue *sizeValue = [movie attributeForKey:QTMovieNaturalSizeAttribute];
	NSSize newMaxSize = maxSizeForFrame([sizeValue sizeValue], size);
	
	NSDictionary *imgProp = [NSDictionary dictionaryWithObjectsAndKeys:
							 QTMovieFrameImageTypeCGImageRef,QTMovieFrameImageType,
							 [NSValue valueWithSize:newMaxSize], QTMovieFrameImageSize,
							 nil];
	XspfQTTimeTransformer *t = [[[XspfQTTimeTransformer alloc] init] autorelease];
	NSValue *qtTime = [t reverseTransformedValue:[NSNumber numberWithDouble:time]];
	
	if(QLThumbnailRequestIsCancelled(thumbnail)) {
		return NULL;
	}
	
	CGImageRef theImage = (CGImageRef)[movie frameImageAtTime:[qtTime QTTimeValue]
											   withAttributes:imgProp
														error:&theErr];
    if (theImage == nil) {
        if (theErr != nil) {
            NSLog(@"Couldn't create CGImageRef, error = %@", theErr);
        }
        return NULL;
    }
	
	return theImage;
}
