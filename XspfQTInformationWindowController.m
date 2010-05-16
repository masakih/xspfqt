//
//  XspfQTInformationWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/14.
//

/*
 Copyright (c) 2008-2010, masakih
 All rights reserved.
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2008-2010, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1, Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3, The names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "XspfQTInformationWindowController.h"
#import "XspfQTDocument.h"


static NSString *const XspfQTDocumentQtMovieKeyPath = @"playingMovie";
static NSString *const XspfQTCurrentTrackKey = @"currentTrack";

@implementation XspfQTInformationWindowController
static XspfQTInformationWindowController *sharedInstance = nil;

+ (XspfQTInformationWindowController *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
			sharedInstance = [[super allocWithZone:NULL] init];
		}
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark-
- (id)init
{
	[super initWithWindowNibName:@"XspfQTImformation"];
	observedDocs = [[NSMutableArray array] retain];
	return self;
}

+ (NSSet *)keyPathsForValuesAffectingMovieAttributes
{
	return [NSSet setWithObject:XspfQTCurrentTrackKey];
}
+ (NSSet *)keyPathsForValuesAffectingSoundTrackAttributes
{
	return [NSSet setWithObject:XspfQTCurrentTrackKey];
}
+ (NSSet *)keyPathsForValuesAffectingVideoTrackAttributes
{
	return [NSSet setWithObject:XspfQTCurrentTrackKey];
}
- (void)notify
{
	[self willChangeValueForKey:XspfQTCurrentTrackKey];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:XspfQTCurrentTrackKey
			   afterDelay:0.0];
}
- (void)currentDocumentDidChangeNotification:(id)notification
{
	[self willChangeValueForKey:@"currentDocument"];
	[self performSelector:@selector(didChangeValueForKey:)
			   withObject:@"currentDocument"
			   afterDelay:0.0];
}

- (void)windowDidLoad
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(currentDocumentDidChangeNotification:)
			   name:NSWindowDidBecomeMainNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(currentDocumentDidChangeNotification:)
			   name:NSWindowDidResignMainNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:NSWindowDidResizeNotification
			 object:nil];
	
	
	[nc addObserver:self
		   selector:@selector(xspfDocumentWillCloseNotification:)
			   name:XspfQTDocumentWillCloseNotification
			 object:nil];
	
}
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[observedDocs release];
	
	[super dealloc];
}

- (void)addObservingDocument:(id)doc
{
	if(!doc) return;
	
	if(![observedDocs containsObject:doc]) {
		[doc addObserver:self
			  forKeyPath:XspfQTDocumentQtMovieKeyPath
				 options:0
				 context:NULL];
		[observedDocs addObject:doc];
	}
}
- (id)currentDocument
{
	id doc = [[NSDocumentController sharedDocumentController] currentDocument];
	if(!doc) return nil;
	[self addObservingDocument:doc];
	
	return doc;
}
- (id)currentTrack
{
	id doc = [self currentDocument];
	
	return [doc valueForKeyPath:@"trackList.currentTrack"];
}
- (id)movieAttributes
{
	id doc = [self currentDocument];
	
	return [doc valueForKeyPath:@"playingMovie.movieAttributes"];
}

- (id)trackAttributesByType:(NSString *)type
{
	id doc = [self currentDocument];
	
	id movie = [doc valueForKeyPath:XspfQTDocumentQtMovieKeyPath];
	NSArray *tracks = [movie tracksOfMediaType:type];
	if(!tracks || [tracks count] == 0) return nil;
	
	return [[tracks objectAtIndex:0] trackAttributes];
}
- (id)soundTrackAttributes
{
	return [self trackAttributesByType:QTMediaTypeSound];
}
- (id)videoTrackAttributes
{
	return [self trackAttributesByType:QTMediaTypeVideo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:XspfQTDocumentQtMovieKeyPath]) {
		[self notify];
	}
}

- (void)xspfDocumentWillCloseNotification:(id)notification
{
	id doc = [notification object];
	
	if(![observedDocs containsObject:doc]) return;
	
	[doc removeObserver:self forKeyPath:XspfQTDocumentQtMovieKeyPath];
	[observedDocs removeObject:doc];
	[docController setContent:nil];
	[currentTrackController setContent:nil];
	
	[self notify];
}
- (void)notifee:(id)notification
{
	[self notify];
}

@end
