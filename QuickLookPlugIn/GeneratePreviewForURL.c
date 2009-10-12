#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <QTKit/QTKit.h>

#import "XspfQTDocument.h"
#import "XspfQTComponent.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
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
    CFDataRef theData = (CFDataRef)[theMovie movieFormatRepresentation];
    QLPreviewRequestSetDataRepresentation(preview, theData, kUTTypeMovie, NULL);
	
fail:
	[pool release];
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
