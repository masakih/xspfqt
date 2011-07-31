//
//  XspfQTDocument.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2008-2010, masakih
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
 Copyright (c) 2008-2010, masakih
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

#import "XspfQTDocument.h"
#import "XspfQTAppDelegate.h"
#import "XspfQTPreference.h"
#import "HMXSPFComponent.h"
#import "XspfQTMovieWindowController.h"
#import "XspfQTPlayListWindowController.h"
#import <QTKit/QTKit.h>

#import "NSURL-HMExtensions.h"
#import "XspfQTMovieLoader.h"
#import "XspfQTValueTransformers.h"

#import "XspfQTMovieTimer.h"


#pragma mark #### Global Variables ####
/********* Global variables *******/
NSString *XspfQTDocumentWillCloseNotification = @"XspfQTDocumentWillCloseNotification";

/**********************************/

@interface XspfQTDocument (Private)
- (void)setPlaylist:(HMXSPFComponent *)newList;
- (HMXSPFComponent *)playlist;
- (NSXMLDocument *)XMLDocument;
- (void)setPlayingMovie:(QTMovie *)newMovie;
- (NSData *)dataFromURL:(NSURL *)url error:(NSError **)outError;

inline static BOOL isXspfFileType(NSString *typeName);
inline static BOOL isReadableMovieType(NSString *typeName);
@end

static NSString *XspfDocumentType = @"XML Shareable Playlist Format";
static NSString *QuickTimeMovieDocumentType = @"QuickTime Movie";
static NSString *MatroskaVideoDocumentType =  @"Matroska Video";
static NSString *DivXMediaFormatDocumentType =  @"DivX Media Format";

static NSString *XspfUTI = @"com.masakih.xspf";

static NSString *XspfQTCurrentTrackKey = @"currentTrack";

@implementation XspfQTDocument

static XspfQTMovieTimer* timer = nil;
+ (void)initialize
{
	timer = [[XspfQTMovieTimer movieTimer] retain];
}

- (id)init
{
	self = [super init];
	if(self) {
		loader = [[XspfQTMovieLoader loaderWithMovieURL:nil delegate:nil] retain];
	}
	
	return self;
}
- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
	[self init];
	
	id newPlaylist = [HMXSPFComponent xspfPlaylist];
	if(!newPlaylist) {
		[self autorelease];
		return nil;
	}
	
	[self setPlaylist:newPlaylist];
	
	return self;
}
- (void)dealloc
{
	[self setPlayingMovie:nil];
	[self setPlaylist:nil];
	[playListWindowController release];
	[movieWindowController release];
	[loader release];
	
	[super dealloc];
}

- (void)makeWindowControllers
{
	playListWindowController = [[XspfQTPlayListWindowController alloc] init];
	[self addWindowController:playListWindowController];
	
	movieWindowController = [[XspfQTMovieWindowController alloc] init];
	[movieWindowController setShouldCloseDocument:YES];
	[self addWindowController:movieWindowController];
	
	[[playListWindowController window] setParentWindow:[movieWindowController window]];
	
	[timer put:self];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	return [[self XMLDocument] XMLDataWithOptions:NSXMLNodePrettyPrint];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if(!isReadableMovieType(typeName)) {
		NSData *data = [self dataFromURL:absoluteURL error:outError];
		if(!data) return NO;
		
		return [self readFromData:data ofType:typeName error:outError];
	}
	
	id new = [HMXSPFComponent xspfTrackWithLocation:absoluteURL];
	if(!new) {
		if(outError) {
			*outError = [NSError errorWithDomain:@"XspfQTErrorDomain" code:1 userInfo:nil];
		}
		return NO;
	}
	
	id pl = [HMXSPFComponent xspfPlaylist];
	if(!pl) {
		return NO;
	}
	
	[[[pl children] objectAtIndex:0] addChild:new];
	
	[self setPlaylist:pl];
	id t = [self trackList];
	if(![t title]) {
		[t setTitle:[[[self fileURL] path] lastPathComponent]];
	}
	
	[self setFileType:XspfDocumentType];
	[self setFileURL:nil];
	
	return YES;
}
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	if(!isXspfFileType(typeName)) {
		return NO;
	}
	
	NSError *error = nil;
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithData:data
													options:0
													  error:&error] autorelease];
	if(error) {
		NSLog(@"%@", error);
		if(outError) {
			*outError = error;
		}
		return NO;
	}
	NSXMLElement *root = [d rootElement];
	id pl = [HMXSPFComponent xspfComponentWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create HMXSPFComponent.");
		return NO;
	}
	[self setPlaylist:pl];
	
	id t = [self trackList];
	if(![t title]) {
		[t setTitle:[[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension]];
	}
		
    return YES;
}

- (void)close
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfQTDocumentWillCloseNotification object:self];
	
	[self removeWindowController:playListWindowController];
	[playListWindowController release];
	playListWindowController = nil;
	
	[self removeWindowController:movieWindowController];
	[movieWindowController release];
	movieWindowController = nil;
	
	[super close];
}

#pragma mark### Actions ###
- (IBAction)togglePlayAndPause:(id)sender
{
	[movieWindowController togglePlayAndPause:sender];
}
- (IBAction)showPlayList:(id)sender
{
	[playListWindowController showWindow:self];
}
- (IBAction)showHidePlayList:(id)sender
{
	[playListWindowController showHideWindow:self];
}
- (IBAction)setThumbnailFrame:(id)sender
{
	HMXSPFComponent *currentTrack = [[self trackList] currentTrack];
	QTTime currentQTTime = [playingMovie currentTime];
	
	NSTimeInterval currentTI;
	QTGetTimeInterval(currentQTTime, &currentTI);
	
	HMXSPFComponent *prevThumbnailTrack = [playlist thumbnailTrack];
	NSTimeInterval ti = [playlist thumbnailTimeInterval];
	
	[playlist setThumbnailComponent:currentTrack timeIntarval:currentTI];
	
	id undo = [self undoManager];
	if(prevThumbnailTrack) {
		[[undo prepareWithInvocationTarget:playlist] setThumbnailComponent:prevThumbnailTrack timeIntarval:ti];
		[undo setActionName:NSLocalizedString(@"Change Thumbnail frame.", @"Undo Action Name Change Thumbnail frame")];
	} else {
		[[undo prepareWithInvocationTarget:playlist] removeThumbnailFrame];
		[undo setActionName:NSLocalizedString(@"Add Thumbnail frame.", @"Undo Action Name Add Thumbnail frame")];
	}
}
- (IBAction)removeThumbnail:(id)sender
{
	HMXSPFComponent *prevThumbnailTrack = [playlist thumbnailTrack];
	NSTimeInterval ti = [playlist thumbnailTimeInterval];
	
	[playlist removeThumbnailFrame];
	
	if(prevThumbnailTrack) {
		id undo = [self undoManager];
		[[undo prepareWithInvocationTarget:playlist] setThumbnailComponent:prevThumbnailTrack timeIntarval:ti];
		[undo setActionName:NSLocalizedString(@"Remove Thumbnail frame.", @"Undo Action Name Remove Thumbnail frame")];
	}
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if(action == @selector(removeThumbnail:)) {
		HMXSPFComponent *component = [playlist thumbnailTrack];
		if(!component) return NO;
	}
	
	return YES;
}

- (void)setPlaylist:(HMXSPFComponent *)newList
{
	if(playlist == newList) return;
	
	[[playlist childAtIndex:0] removeObserver:self forKeyPath:XspfQTCurrentTrackKey];
	[playlist autorelease];
	playlist = [newList retain];
	[[playlist childAtIndex:0] addObserver:self
								forKeyPath:XspfQTCurrentTrackKey
								   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
								   context:NULL];
}
- (HMXSPFComponent *)playlist
{
	return playlist;
}

- (HMXSPFComponent *)trackList
{
	return [playlist childAtIndex:0];
}

+ (NSSet *)keyPathsForValuesAffectingPlayingMovieDuration
{
	return [NSSet setWithObject:@"playingMovie"];
}
- (void)setPlayingMovie:(QTMovie *)newMovie
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	if(playingMovie) {
		[nc removeObserver:self
					  name:nil
					object:playingMovie];
	}
	
	[playingMovie autorelease];
	playingMovie = [newMovie retain];
	playingMovieDuration = 0;
	
	if(playingMovie) {
		[nc addObserver:self
			   selector:@selector(notifee:)
				   name:QTMovieRateDidChangeNotification
				 object:playingMovie];
	}
}
- (QTMovie *)playingMovie
{
	return playingMovie;
}
- (NSTimeInterval)playingMovieDuration
{
	if(playingMovieDuration == 0) {
		QTTime qttime = [[self playingMovie] duration];
		if(!QTGetTimeInterval(qttime, &playingMovieDuration)) playingMovieDuration = 0;
	}
	
	return playingMovieDuration;
}
- (void)loadMovie
{
	NSURL *location = [[self trackList] movieLocation];
	
	if(playingMovie) {
		id movieURL = [playingMovie attributeForKey:QTMovieURLAttribute];
		if([location isEqualUsingLocalhost:movieURL]) return;
	}
	
	[loader setMovieURL:location];
	[loader load];
	QTMovie *newMovie = [loader qtMovie];
	[self setPlayingMovie:newMovie];
	
	QTTime qttime = [newMovie duration];
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	[[self trackList] setCurrentTrackDuration:[t transformedValue:[NSValue valueWithQTTime:qttime]]];
	
	didPreloading = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:XspfQTCurrentTrackKey]) {
		[self loadMovie];
	}
}

- (NSXMLDocument *)XMLDocument
{
	id root = [[self playlist] XMLElement];
	
	id d = [[[NSXMLDocument alloc] initWithRootElement:root] autorelease];
	[d setVersion:@"1.0"];
	[d setCharacterEncoding:@"UTF-8"];
	
	return d;
}

- (void)insertComponentFromURL:(NSURL *)url atIndex:(NSUInteger)index
{
	id new = [HMXSPFComponent xspfTrackWithLocation:url];
	if(!new) {
		@throw self;
	}
	
	[self insertComponent:new atIndex:index];
}
- (void)insertComponent:(HMXSPFComponent *)item atIndex:(NSUInteger)index
{
	id undo = [self undoManager];
	[undo registerUndoWithTarget:self selector:@selector(removeComponent:) object:item];
	[[self trackList] insertChild:item atIndex:index];
	[undo setActionName:NSLocalizedString(@"Insert Movie", @"Undo Action Name Insert Movie")];
}
- (void)removeComponent:(HMXSPFComponent *)item
{
	NSUInteger index = [[self trackList] indexOfChild:item];
	if(index == NSNotFound) {
		NSLog(@"Can not found item (%@)", item); 
		return;
	}
	
	id undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertComponent:item atIndex:index];
	[[self trackList] removeChild:item];
	[undo setActionName:NSLocalizedString(@"Remove Movie", @"Undo Action Name Remove Movie")];
}
- (void)moveComponentFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{	
	id undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] moveComponentFromIndex:to toIndex:from];
	[[self trackList] moveChildFromIndex:from toIndex:to];
	[undo setActionName:NSLocalizedString(@"Move Movie", @"Undo Action Name Move Movie")];
}
- (void)moveComponent:(HMXSPFComponent *)item toIndex:(NSUInteger)index
{
	NSUInteger from = [[self trackList] indexOfChild:item];
	if(from == NSNotFound) return;
	[self moveComponentFromIndex:from toIndex:index];
}

- (NSData *)dataFromURL:(NSURL *)url error:(NSError **)outError
{
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	NSURLResponse *res = nil;
	NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:req
										 returningResponse:&res
													 error:&err];
	if(err) {
		if(outError) {
			*outError = err;
		}
		return nil;
	}
	
	return data;
}

- (void)notifee:(id)notification
{
	//	NSLog(@"Notifed: name -> (%@)\ndict -> (%@)", [notification name], [notification userInfo]);
	
	id track = [[self trackList] currentTrack];
	NSNumber *rateValue = [[notification userInfo] objectForKey:QTMovieRateDidChangeNotificationParameter];
	if(rateValue) {
		float rate = [rateValue floatValue];
		if(rate == 0) {
			[track setIsPlayed:NO];
		} else {
			[track setIsPlayed:YES];
		}
	}
}

// call from XspfQTMovieTimer.
- (void)checkPreload:(NSTimer *)timer
{
	if(![XspfQTPref preloadingEnabled]) return;
	if(didPreloading) return;
	
	NSTimeInterval duration;
	NSTimeInterval current;
	QTTime qttime = [playingMovie currentTime];
	if(!QTGetTimeInterval(qttime, &current)) return;
	
	duration = [self playingMovieDuration];
	
	if( current / duration > [XspfQTPref beginingPreloadPercent] ) {
		didPreloading = YES;
		HMXSPFComponent *list = [self trackList];
		NSUInteger nextIndex = [list selectionIndex] + 1;
		NSUInteger max = [list childrenCount];
		if(max <= nextIndex) return;
		
		HMXSPFComponent *nextTrack = [list childAtIndex:nextIndex];
		NSURL *nextMovieURL = [nextTrack movieLocation];
		[loader setMovieURL:nextMovieURL];
		[loader load];
	}
}

inline static BOOL isXspfFileType(NSString *typeName)
{
	return [typeName isEqualToString:XspfDocumentType] || [typeName isEqualToString:XspfUTI];
}
inline static BOOL isReadableMovieType(NSString *typeName)
{
	return [typeName isEqualToString:QuickTimeMovieDocumentType]
	|| [typeName isEqualToString:MatroskaVideoDocumentType]
	|| [typeName isEqualToString:DivXMediaFormatDocumentType];
}

@end

