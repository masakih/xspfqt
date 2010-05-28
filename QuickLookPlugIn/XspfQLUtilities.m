/*
 *  XspfQLUtilities.c
 *  XspfQT
 *
 *  Created by Hori, Masaki on 09/10/12.
 *
 */

/*
 This source code is release under the New BSD License.
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に
 限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含
 めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表
 示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、
 コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、
 明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証
 も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューター
 も、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか
 厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する
 可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用
 サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定
 されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害につい
 て、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2009-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1, Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
 3, The names of its contributors may be used to endorse or promote
    products derived from this software without specific prior
    written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
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
	HMXSPFComponent *pl = [HMXSPFComponent xspfComponentWithXMLElement:root];
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
