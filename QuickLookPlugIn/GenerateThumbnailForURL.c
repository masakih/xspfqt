#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <QTKit/QTKit.h>

#include "XspfQLUtilities.h"
#import "XspfQTValueTransformers.h"


/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSError *theErr = nil;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    QTMovie *theMovie = firstMovie(url);
    if (theMovie == nil) {
        goto fail;
    }
	
	if(QLThumbnailRequestIsCancelled(thumbnail)) {
		goto fail;
	}
	
	XspfQTTimeTransformer *t = [[[XspfQTTimeTransformer alloc] init] autorelease];
	
	
	/** はじめのフレームは真っ黒、あるいは真っ白である場合が多い。そのため以下の秒数のフレームを使用する。
	 ** ０、ポスターフレームがあればそれを使用。
	 ** １、１５分以上なら秒数で１％のフレームを使用。
	 ** ２、１分以上なら１秒目のフレームを使用。
	 ** ３、それらよりも短いときは０秒目のフレームを使用。
	 **/
	NSValue *pTimeValue = [theMovie attributeForKey:QTMoviePosterTimeAttribute];
	id pV = [t transformedValue:pTimeValue];
	if([pV longValue] == 0) {
		NSValue *duration = [theMovie attributeForKey:QTMovieDurationAttribute];
		id v = [t transformedValue:duration];
		
		double newPosterTime = 0;
		double dDur = [v doubleValue];
		if(dDur > 15 * 60) {
			newPosterTime = dDur / 100;
		} else if(dDur > 60) {
			newPosterTime = 1;
		}
		pTimeValue = [t reverseTransformedValue:[NSNumber numberWithDouble:newPosterTime]];
	}
//	NSLog(@"Poster time is -> (%@)", QTStringFromTime([pTimeValue QTTimeValue]));
	
	NSDictionary *imgProp = [NSDictionary dictionaryWithObject:QTMovieFrameImageTypeCGImageRef forKey:QTMovieFrameImageType];
	CGImageRef theImage = (CGImageRef)[theMovie frameImageAtTime:[pTimeValue QTTimeValue] withAttributes:imgProp error:&theErr];
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
