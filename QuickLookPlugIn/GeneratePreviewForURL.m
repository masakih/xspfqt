#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>

#import <QTKit/QTKit.h>

#import "XspfQLUtilities.h"

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	OSStatus err = noErr;
	
	QTMovie *theMovie = firstMovie(url);
    if (theMovie == nil) {
		err = -10000;
        goto fail;
    }
	
	if(QLPreviewRequestIsCancelled(preview)) {
		goto fail;
	}
	
    CFDataRef theData = (CFDataRef)[theMovie movieFormatRepresentation];
    QLPreviewRequestSetDataRepresentation(preview, theData, kUTTypeMovie, NULL);
	
fail:
	[pool release];
    return err;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
