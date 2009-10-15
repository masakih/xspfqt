#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <QTKit/QTKit.h>

#include "XspfQLUtilities.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	QTMovie *theMovie = firstMovie(url);
    if (theMovie == nil) {
        goto fail;
    }
	
	if(QLPreviewRequestIsCancelled(preview)) {
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
