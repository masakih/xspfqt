#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <QTKit/QTKit.h>

#import "XspfQTDocument.h"
#import "XspfQTComponent.h"

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSError *theErr = nil;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
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
		NSLog(@"Can not get movei URL.");
	} else {
		NSLog(@"Movie URL is %@.", movieURL);
	}
	
    QTMovie *theMovie = [QTMovie movieWithURL:movieURL error:&theErr];
    if (theMovie == nil) {
        if (theErr != nil) {
            NSLog(@"Couldn't load movie URL, error = %@", theErr);
        }
        goto fail;
    }
    [theMovie gotoPosterTime];
    QTTime mTime = [theMovie currentTime];
    NSDictionary *imgProp = [NSDictionary dictionaryWithObject:QTMovieFrameImageTypeCGImageRef forKey:QTMovieFrameImageType];
    CGImageRef theImage = (CGImageRef)[theMovie frameImageAtTime:mTime withAttributes:imgProp error:&theErr];
//	CGImageRef theImage = (CGImageRef)[theMovie posterImage];
	
    if (theImage == nil) {
        if (theErr != nil) {
            NSLog(@"Couldn't create CGImageRef, error = %@", theErr);
        }
        goto fail;
    }
    QLThumbnailRequestSetImage(thumbnail, theImage, NULL);
	
fail:
	[pool release];
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
