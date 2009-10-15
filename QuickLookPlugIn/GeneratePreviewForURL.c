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
	
	NSURL *theMovieURL = firstMovieURL(url);
    if (theMovieURL == nil) {
        goto fail;
    }
	
	if(QLPreviewRequestIsCancelled(preview)) {
		goto fail;
	}
	NSError *error = nil;
    CFDataRef theData = (CFDataRef)[NSData dataWithContentsOfURL:theMovieURL options:0 error:&error];
	if(!theData) {
		if(error) {
			NSLog(@"Can not read move, error = %@", error);
		}
		goto fail;
	}
    QLPreviewRequestSetDataRepresentation(preview, theData, kUTTypeMovie, NULL);
	
fail:
	[pool release];
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
