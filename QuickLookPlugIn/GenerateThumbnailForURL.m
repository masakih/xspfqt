#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>

#import <QTKit/QTKit.h>

#import "XspfQLUtilities.h"
#import "XspfQTValueTransformers.h"


/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSError *theErr = nil;
	OSStatus err = noErr;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// generate from XML.
	do {
		NSTimeInterval time = DBL_MIN;
		XspfQTComponent *component = thumbnailTrack(url, &time);
		if(!component) break;
		if(time ==  DBL_MIN) break;
		if(QLThumbnailRequestIsCancelled(thumbnail)) {
			goto fail;
		}
		
		CGImageRef aThumbnail = thumbnailForTrackTime(thumbnail, component, time, maxSize);
		if(aThumbnail) {
			QLThumbnailRequestSetImage(thumbnail, aThumbnail, NULL);
			goto fail;
		}
	} while(NO);
	
	// generate from first movie.
    QTMovie *theMovie = firstMovie(url);
    if (theMovie == nil) {
		err = -10000;
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
	
	NSValue *size = [theMovie attributeForKey:QTMovieNaturalSizeAttribute];
	NSSize newMaxSize = maxSizeForFrame([size sizeValue], maxSize);
	
	NSDictionary *imgProp = [NSDictionary dictionaryWithObjectsAndKeys:
							 QTMovieFrameImageTypeCGImageRef,QTMovieFrameImageType,
							 [NSValue valueWithSize:newMaxSize], QTMovieFrameImageSize,
							 nil];
	CGImageRef theImage = (CGImageRef)[theMovie frameImageAtTime:[pTimeValue QTTimeValue] withAttributes:imgProp error:&theErr];
    if (theImage == nil) {
        if (theErr != nil) {
            NSLog(@"Couldn't create CGImageRef, error = %@", theErr);
        }
		err = -1001;
        goto fail;
    }
	
    QLThumbnailRequestSetImage(thumbnail, theImage, NULL);
	
fail:
	[pool release];
    return err;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
