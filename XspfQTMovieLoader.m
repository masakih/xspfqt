//
//  XspfQTMovieLoader.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/14.
<<<<<<< HEAD:XspfQTMovieLoader.m
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTMovieLoader.h"

#import "NSURL-XspfQT-Extensions.h"

@implementation XspfQTMovieLoader
+ (id)loaderWithMovieURL:(NSURL *)inMovieURL delegate:(id)inDelegate
{
	return [[[[self class] alloc] initWithMovieURL:inMovieURL delegate:inDelegate] autorelease];
}
- (id)initWithMovieURL:(NSURL *)inMovieURL delegate:(id)inDelegate
=======
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2009-2010,2012, masakih
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
 Copyright (c) 2009-2010,2012, masakih
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

#import "XspfQTMovieLoader.h"

#import "NSURL-HMExtensions.h"

@interface XspfQTMovieLoader()
@property (readwrite, retain) QTMovie *qtMovie;
@end;

@implementation XspfQTMovieLoader
@synthesize movieURL = _movieURL;
@synthesize qtMovie = _qtMovie;
@synthesize delegate = _delegate;


+ (id)loaderWithMovieURL:(NSURL *)moviewURL
{
	return [[[self alloc] initWithMovieURL:moviewURL delegate:nil] autorelease];
}
- (id)initWithMovieURL:(NSURL *)moviewURL
{
	return [self initWithMovieURL:moviewURL delegate:nil];
}

+ (id)loaderWithMovieURL:(NSURL *)inMovieURL delegate:(id<XspfQTMovieLoaderDelegate>)inDelegate
{
	return [[[[self class] alloc] initWithMovieURL:inMovieURL delegate:inDelegate] autorelease];
}
- (id)initWithMovieURL:(NSURL *)inMovieURL delegate:(id<XspfQTMovieLoaderDelegate>)inDelegate
>>>>>>> trunk:XspfQTMovieLoader.m
{
	self = [super init];
	if(self) {
		
		@try {
<<<<<<< HEAD:XspfQTMovieLoader.m
			[self setDelegate:inDelegate];
=======
			self.delegate = inDelegate;
>>>>>>> trunk:XspfQTMovieLoader.m
		}
		@catch (XspfQTMovieLoader *me) {
			[self autorelease];
			return nil;
		}
<<<<<<< HEAD:XspfQTMovieLoader.m
		[self setMovieURL:inMovieURL];
=======
		self.movieURL = inMovieURL;
>>>>>>> trunk:XspfQTMovieLoader.m
	}
	
	return self;
}

- (void)dealloc
{
<<<<<<< HEAD:XspfQTMovieLoader.m
	[movieURL release];
	[movie release];
=======
	self.movieURL = nil;
	self.qtMovie = nil;
>>>>>>> trunk:XspfQTMovieLoader.m
	
	[super dealloc];
}

- (void)setMovieURL:(NSURL *)url
{
<<<<<<< HEAD:XspfQTMovieLoader.m
	if([url isEqualUsingLocalhost:movieURL]) return;
	
	[self setQTMovie:nil];
	[movieURL autorelease];
	movieURL = [url retain];
}
- (NSURL *)movieURL
{
	return movieURL;
}
- (void)setQTMovie:(QTMovie *)newMovie
{
	[movie release];
	movie = [newMovie retain];
}
- (QTMovie *)qtMovie
{
	return movie;
}

- (void)setDelegate:(id)inDelegate
{
	if(inDelegate && ![inDelegate respondsToSelector:@selector(setQTMovie:)]) {
		NSLog(@"Delegate should be respond to selector setQTMovie:");
		@throw self;
	}
	
	delegate = inDelegate;
}
- (id)delegate
{
	return delegate;
=======
	if([url isEqualUsingLocalhost:_movieURL]) return;
	
	self.qtMovie = nil;
	[_movieURL autorelease];
	_movieURL = [url retain];
}
- (NSURL *)movieURL
{
	return _movieURL;
>>>>>>> trunk:XspfQTMovieLoader.m
}

- (void)load
{
	QTMovie *newMovie = nil;
	
<<<<<<< HEAD:XspfQTMovieLoader.m
	if(movie) return;
		
	if(![QTMovie canInitWithURL:movieURL]) goto finish;
	
	NSError *error = nil;
	//	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
	//						   [self location], QTMovieURLAttribute,
	//						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
	//						   nil];
	//	movie = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	newMovie = [[QTMovie alloc] initWithURL:movieURL error:&error];
=======
	if(self.qtMovie) return;
		
	if(![QTMovie canInitWithURL:self.movieURL]) goto finish;
	
	NSError *error = nil;
	newMovie = [[QTMovie alloc] initWithURL:self.movieURL error:&error];
>>>>>>> trunk:XspfQTMovieLoader.m
	if(error) {
		NSLog(@"%@", error);
	}
	
finish:
<<<<<<< HEAD:XspfQTMovieLoader.m
	[self setQTMovie:[newMovie autorelease]];
	[delegate setQTMovie:movie];
=======
	self.qtMovie = [newMovie autorelease];
	[self.delegate setQTMovie:self.qtMovie];
>>>>>>> trunk:XspfQTMovieLoader.m
}
- (void)loadInBG
{
	[self performSelector:@selector(load) withObject:nil afterDelay:0.0];
}

@end
