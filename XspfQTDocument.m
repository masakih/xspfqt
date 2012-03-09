//
//  XspfQTDocument.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
<<<<<<< HEAD:XspfQTDocument.m
//  Copyright masakih 2008 . All rights reserved.
//

#import "XspfQTDocument.h"
#import "XspfQTAppDelegate.h"
#import "XspfQTPreference.h"
#import "XspfQTComponent.h"
=======
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2008-2010,2012, masakih
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
 Copyright (c) 2008-2010,2012, masakih
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
>>>>>>> trunk:XspfQTDocument.m
#import "XspfQTMovieWindowController.h"
#import "XspfQTPlayListWindowController.h"
#import <QTKit/QTKit.h>

<<<<<<< HEAD:XspfQTDocument.m
#import "NSURL-XspfQT-Extensions.h"
=======
#import "NSURL-HMExtensions.h"
>>>>>>> trunk:XspfQTDocument.m
#import "XspfQTMovieLoader.h"
#import "XspfQTValueTransformers.h"

#import "XspfQTMovieTimer.h"


#pragma mark #### Global Variables ####
/********* Global variables *******/
NSString *XspfQTDocumentWillCloseNotification = @"XspfQTDocumentWillCloseNotification";

/**********************************/

<<<<<<< HEAD:XspfQTDocument.m
@interface XspfQTDocument (Private)
- (void)setPlaylist:(XspfQTComponent *)newList;
- (XspfQTComponent *)playlist;
- (NSXMLDocument *)XMLDocument;
- (void)setPlayingMovie:(QTMovie *)newMovie;
=======
@interface XspfQTDocument()
@property (retain) HMXSPFComponent *playlist;
@property (retain) QTMovie *playingMovie;
@property (readonly) NSXMLDocument *XMLDocument;

// private 
@property (retain) XspfQTMovieLoader *loader;
@property NSTimeInterval playingMovieDuration;
@property BOOL didPreloading;
@end

@interface XspfQTDocument (Private)
>>>>>>> trunk:XspfQTDocument.m
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
<<<<<<< HEAD:XspfQTDocument.m
=======
@synthesize playlist = _playlist;
@synthesize playingMovie = _playingMovie;

@synthesize loader = _loader;
@synthesize playingMovieDuration = _playingMovieDuration;
@synthesize didPreloading = _didPreloading;
>>>>>>> trunk:XspfQTDocument.m

static XspfQTMovieTimer* timer = nil;
+ (void)initialize
{
	timer = [[XspfQTMovieTimer movieTimer] retain];
}

- (id)init
{
	self = [super init];
	if(self) {
<<<<<<< HEAD:XspfQTDocument.m
		loader = [[XspfQTMovieLoader loaderWithMovieURL:nil delegate:nil] retain];
=======
		self.loader = [[XspfQTMovieLoader loaderWithMovieURL:nil] retain];
>>>>>>> trunk:XspfQTDocument.m
	}
	
	return self;
}
- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
	[self init];
	
<<<<<<< HEAD:XspfQTDocument.m
	id newPlaylist = [XspfQTComponent xspfPlaylist];
=======
	id newPlaylist = [HMXSPFComponent xspfPlaylist];
>>>>>>> trunk:XspfQTDocument.m
	if(!newPlaylist) {
		[self autorelease];
		return nil;
	}
	
<<<<<<< HEAD:XspfQTDocument.m
	[self setPlaylist:newPlaylist];
=======
	self.playlist = newPlaylist;
>>>>>>> trunk:XspfQTDocument.m
	
	return self;
}
- (void)dealloc
{
<<<<<<< HEAD:XspfQTDocument.m
	[self setPlayingMovie:nil];
	[self setPlaylist:nil];
	[playListWindowController release];
	[movieWindowController release];
	[loader release];
=======
	self.playingMovie = nil;
	self.playlist = nil;
	[playListWindowController release];
	[movieWindowController release];
	self.loader = nil;
>>>>>>> trunk:XspfQTDocument.m
	
	[super dealloc];
}

- (void)makeWindowControllers
{
	playListWindowController = [[XspfQTPlayListWindowController alloc] init];
	[self addWindowController:playListWindowController];
	
	movieWindowController = [[XspfQTMovieWindowController alloc] init];
	[movieWindowController setShouldCloseDocument:YES];
	[self addWindowController:movieWindowController];
	
<<<<<<< HEAD:XspfQTDocument.m
=======
	[movieWindowController showWindow:nil];
	
>>>>>>> trunk:XspfQTDocument.m
	[timer put:self];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
<<<<<<< HEAD:XspfQTDocument.m
	return [[self XMLDocument] XMLDataWithOptions:NSXMLNodePrettyPrint];
=======
	return [self.XMLDocument XMLDataWithOptions:NSXMLNodePrettyPrint];
>>>>>>> trunk:XspfQTDocument.m
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	if(!isReadableMovieType(typeName)) {
		NSData *data = [self dataFromURL:absoluteURL error:outError];
		if(!data) return NO;
		
		return [self readFromData:data ofType:typeName error:outError];
	}
	
<<<<<<< HEAD:XspfQTDocument.m
	id new = [XspfQTComponent xspfTrackWithLocation:absoluteURL];
=======
	id new = [HMXSPFComponent xspfTrackWithLocation:absoluteURL];
>>>>>>> trunk:XspfQTDocument.m
	if(!new) {
		if(outError) {
			*outError = [NSError errorWithDomain:@"XspfQTErrorDomain" code:1 userInfo:nil];
		}
		return NO;
	}
	
<<<<<<< HEAD:XspfQTDocument.m
	id pl = [XspfQTComponent xspfPlaylist];
=======
	id pl = [HMXSPFComponent xspfPlaylist];
>>>>>>> trunk:XspfQTDocument.m
	if(!pl) {
		return NO;
	}
	
	[[[pl children] objectAtIndex:0] addChild:new];
	
<<<<<<< HEAD:XspfQTDocument.m
	[self setPlaylist:pl];
	id t = [self trackList];
	if(![t title]) {
		[t setTitle:[[[self fileURL] path] lastPathComponent]];
=======
	self.playlist = pl;
	HMXSPFComponent *t = self.trackList;
	if(!t.title) {
		t.title = [[[self fileURL] path] lastPathComponent];
>>>>>>> trunk:XspfQTDocument.m
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
<<<<<<< HEAD:XspfQTDocument.m
	id pl = [XspfQTComponent xspfComponemtWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create XspfQTComponent.");
		return NO;
	}
	[self setPlaylist:pl];
	
	id t = [self trackList];
	if(![t title]) {
		[t setTitle:[[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension]];
=======
	id pl = [HMXSPFComponent xspfComponentWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create HMXSPFComponent.");
		return NO;
	}
	self.playlist = pl;
	
	HMXSPFComponent *t = self.trackList;
	if(!t.title) {
		t.title = [[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension];
>>>>>>> trunk:XspfQTDocument.m
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
<<<<<<< HEAD:XspfQTDocument.m
		
=======
	
>>>>>>> trunk:XspfQTDocument.m
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
<<<<<<< HEAD:XspfQTDocument.m
- (IBAction)setThumbnailFrame:(id)sender
{
	XspfQTComponent *currentTrack = [[self trackList] currentTrack];
	QTTime currentQTTime = [playingMovie currentTime];
=======
- (IBAction)showHidePlayList:(id)sender
{
	[playListWindowController showHideWindow:self];
}
- (IBAction)setThumbnailFrame:(id)sender
{
	HMXSPFComponent *currentTrack = self.trackList.currentTrack;
	QTTime currentQTTime = [self.playingMovie currentTime];
>>>>>>> trunk:XspfQTDocument.m
	
	NSTimeInterval currentTI;
	QTGetTimeInterval(currentQTTime, &currentTI);
	
<<<<<<< HEAD:XspfQTDocument.m
	XspfQTComponent *prevThumbnailTrack = [playlist thumbnailTrack];
	NSTimeInterval ti = [playlist thumbnailTimeInterval];
	
	[playlist setThumbnailComponent:currentTrack timeIntarval:currentTI];
	
	id undo = [self undoManager];
	if(prevThumbnailTrack) {
		[[undo prepareWithInvocationTarget:playlist] setThumbnailComponent:prevThumbnailTrack timeIntarval:ti];
		[undo setActionName:NSLocalizedString(@"Change Thumbnail frame.", @"Undo Action Name Change Thumbnail frame")];
	} else {
		[[undo prepareWithInvocationTarget:playlist] removeThumbnailFrame];
=======
	HMXSPFComponent *prevThumbnailTrack = self.playlist.thumbnailTrack;
	NSTimeInterval ti = self.playlist.thumbnailTimeInterval;
	
	[self.playlist setThumbnailComponent:currentTrack timeIntarval:currentTI];
	
	id undo = [self undoManager];
	if(prevThumbnailTrack) {
		[[undo prepareWithInvocationTarget:self.playlist] setThumbnailComponent:prevThumbnailTrack timeIntarval:ti];
		[undo setActionName:NSLocalizedString(@"Change Thumbnail frame.", @"Undo Action Name Change Thumbnail frame")];
	} else {
		[[undo prepareWithInvocationTarget:self.playlist] removeThumbnailFrame];
>>>>>>> trunk:XspfQTDocument.m
		[undo setActionName:NSLocalizedString(@"Add Thumbnail frame.", @"Undo Action Name Add Thumbnail frame")];
	}
}
- (IBAction)removeThumbnail:(id)sender
{
<<<<<<< HEAD:XspfQTDocument.m
	XspfQTComponent *prevThumbnailTrack = [playlist thumbnailTrack];
	NSTimeInterval ti = [playlist thumbnailTimeInterval];
	
	[playlist removeThumbnailFrame];
	
	if(prevThumbnailTrack) {
		id undo = [self undoManager];
		[[undo prepareWithInvocationTarget:playlist] setThumbnailComponent:prevThumbnailTrack timeIntarval:ti];
=======
	HMXSPFComponent *prevThumbnailTrack = self.playlist.thumbnailTrack;
	NSTimeInterval ti = self.playlist.thumbnailTimeInterval;
	
	[self.playlist removeThumbnailFrame];
	
	if(prevThumbnailTrack) {
		id undo = [self undoManager];
		[[undo prepareWithInvocationTarget:self.playlist] setThumbnailComponent:prevThumbnailTrack timeIntarval:ti];
>>>>>>> trunk:XspfQTDocument.m
		[undo setActionName:NSLocalizedString(@"Remove Thumbnail frame.", @"Undo Action Name Remove Thumbnail frame")];
	}
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if(action == @selector(removeThumbnail:)) {
<<<<<<< HEAD:XspfQTDocument.m
		XspfQTComponent *component = [playlist thumbnailTrack];
=======
		HMXSPFComponent *component = self.playlist.thumbnailTrack;
>>>>>>> trunk:XspfQTDocument.m
		if(!component) return NO;
	}
	
	return YES;
}

<<<<<<< HEAD:XspfQTDocument.m
- (void)setPlaylist:(XspfQTComponent *)newList
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
- (XspfQTComponent *)playlist
{
	return playlist;
}

- (XspfQTComponent *)trackList
{
	return [playlist childAtIndex:0];
=======
- (void)setPlaylist:(HMXSPFComponent *)newList
{
	if(_playlist == newList) return;
	
	[[_playlist childAtIndex:0] removeObserver:self forKeyPath:XspfQTCurrentTrackKey];
	[_playlist autorelease];
	_playlist = [newList retain];
	[[_playlist childAtIndex:0] addObserver:self
								 forKeyPath:XspfQTCurrentTrackKey
									options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
									context:NULL];
}
- (HMXSPFComponent *)playlist
{
	return _playlist;
}

- (HMXSPFComponent *)trackList
{
	return [self.playlist childAtIndex:0];
>>>>>>> trunk:XspfQTDocument.m
}

+ (NSSet *)keyPathsForValuesAffectingPlayingMovieDuration
{
	return [NSSet setWithObject:@"playingMovie"];
}
- (void)setPlayingMovie:(QTMovie *)newMovie
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
<<<<<<< HEAD:XspfQTDocument.m
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
=======
	if(_playingMovie) {
		[nc removeObserver:self
					  name:nil
					object:_playingMovie];
	}
	
	[_playingMovie autorelease];
	_playingMovie = [newMovie retain];
	self.playingMovieDuration = 0;
	
	if(_playingMovie) {
		[nc addObserver:self
			   selector:@selector(notifee:)
				   name:QTMovieRateDidChangeNotification
				 object:_playingMovie];
>>>>>>> trunk:XspfQTDocument.m
	}
}
- (QTMovie *)playingMovie
{
<<<<<<< HEAD:XspfQTDocument.m
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
=======
	return _playingMovie;
}
- (void)setPlayingMovieDuration:(NSTimeInterval)playingMovieDuration
{
	_playingMovieDuration = playingMovieDuration;
}
- (NSTimeInterval)playingMovieDuration
{
	if(_playingMovieDuration == 0) {
		QTTime qttime = [self.playingMovie duration];
		if(!QTGetTimeInterval(qttime, &_playingMovieDuration)) _playingMovieDuration = 0;
	}
	
	return _playingMovieDuration;
}
- (void)loadMovie
{
	NSURL *location = self.trackList.movieLocation;
	
	if(self.playingMovie) {
		id movieURL = [self.playingMovie attributeForKey:QTMovieURLAttribute];
		if([location isEqualUsingLocalhost:movieURL]) return;
	}
	
	self.loader.movieURL = location;
	[self.loader load];
	QTMovie *newMovie = self.loader.qtMovie;
	self.playingMovie = newMovie;
	
	QTTime qttime = [newMovie duration];
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	[self.trackList setCurrentTrackDuration:[t transformedValue:[NSValue valueWithQTTime:qttime]]];
	
	self.didPreloading = NO;
>>>>>>> trunk:XspfQTDocument.m
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
<<<<<<< HEAD:XspfQTDocument.m
	id root = [[self playlist] XMLElement];
=======
	id root = self.playlist.XMLElement;
>>>>>>> trunk:XspfQTDocument.m
	
	id d = [[[NSXMLDocument alloc] initWithRootElement:root] autorelease];
	[d setVersion:@"1.0"];
	[d setCharacterEncoding:@"UTF-8"];
	
	return d;
}

- (void)insertComponentFromURL:(NSURL *)url atIndex:(NSUInteger)index
{
<<<<<<< HEAD:XspfQTDocument.m
	id new = [XspfQTComponent xspfTrackWithLocation:url];
=======
	id new = [HMXSPFComponent xspfTrackWithLocation:url];
>>>>>>> trunk:XspfQTDocument.m
	if(!new) {
		@throw self;
	}
	
	[self insertComponent:new atIndex:index];
}
<<<<<<< HEAD:XspfQTDocument.m
- (void)insertComponent:(XspfQTComponent *)item atIndex:(NSUInteger)index
{
	id undo = [self undoManager];
	[undo registerUndoWithTarget:self selector:@selector(removeComponent:) object:item];
	[[self trackList] insertChild:item atIndex:index];
	[undo setActionName:NSLocalizedString(@"Insert Movie", @"Undo Action Name Insert Movie")];
}
- (void)removeComponent:(XspfQTComponent *)item
{
	NSUInteger index = [[self trackList] indexOfChild:item];
=======
- (void)insertComponent:(HMXSPFComponent *)item atIndex:(NSUInteger)index
{
	id undo = [self undoManager];
	[undo registerUndoWithTarget:self selector:@selector(removeComponent:) object:item];
	[self.trackList insertChild:item atIndex:index];
	[undo setActionName:NSLocalizedString(@"Insert Movie", @"Undo Action Name Insert Movie")];
}
- (void)removeComponent:(HMXSPFComponent *)item
{
	NSUInteger index = [self.trackList indexOfChild:item];
>>>>>>> trunk:XspfQTDocument.m
	if(index == NSNotFound) {
		NSLog(@"Can not found item (%@)", item); 
		return;
	}
	
	id undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertComponent:item atIndex:index];
<<<<<<< HEAD:XspfQTDocument.m
	[[self trackList] removeChild:item];
=======
	[self.trackList removeChild:item];
>>>>>>> trunk:XspfQTDocument.m
	[undo setActionName:NSLocalizedString(@"Remove Movie", @"Undo Action Name Remove Movie")];
}
- (void)moveComponentFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{	
	id undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] moveComponentFromIndex:to toIndex:from];
<<<<<<< HEAD:XspfQTDocument.m
	[[self trackList] moveChildFromIndex:from toIndex:to];
	[undo setActionName:NSLocalizedString(@"Move Movie", @"Undo Action Name Move Movie")];
}
- (void)moveComponent:(XspfQTComponent *)item toIndex:(NSUInteger)index
{
	NSUInteger from = [[self trackList] indexOfChild:item];
=======
	[self.trackList moveChildFromIndex:from toIndex:to];
	[undo setActionName:NSLocalizedString(@"Move Movie", @"Undo Action Name Move Movie")];
}
- (void)moveComponent:(HMXSPFComponent *)item toIndex:(NSUInteger)index
{
	NSUInteger from = [self.trackList indexOfChild:item];
>>>>>>> trunk:XspfQTDocument.m
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
	
<<<<<<< HEAD:XspfQTDocument.m
	id track = [[self trackList] currentTrack];
=======
	HMXSPFComponent *track = self.trackList.currentTrack;
>>>>>>> trunk:XspfQTDocument.m
	NSNumber *rateValue = [[notification userInfo] objectForKey:QTMovieRateDidChangeNotificationParameter];
	if(rateValue) {
		float rate = [rateValue floatValue];
		if(rate == 0) {
<<<<<<< HEAD:XspfQTDocument.m
			[track setIsPlayed:NO];
		} else {
			[track setIsPlayed:YES];
=======
			track.isPlayed = NO;
		} else {
			track.isPlayed = YES;
>>>>>>> trunk:XspfQTDocument.m
		}
	}
}

// call from XspfQTMovieTimer.
- (void)checkPreload:(NSTimer *)timer
{
	if(![XspfQTPref preloadingEnabled]) return;
<<<<<<< HEAD:XspfQTDocument.m
	if(didPreloading) return;
	
	NSTimeInterval duration;
	NSTimeInterval current;
	QTTime qttime = [playingMovie currentTime];
	if(!QTGetTimeInterval(qttime, &current)) return;
	
	duration = [self playingMovieDuration];
	
	if( current / duration > [XspfQTPref beginingPreloadPercent] ) {
		didPreloading = YES;
		XspfQTComponent *list = [self trackList];
		NSUInteger nextIndex = [list selectionIndex] + 1;
		NSUInteger max = [list childrenCount];
		if(max <= nextIndex) return;
		
		XspfQTComponent *nextTrack = [list childAtIndex:nextIndex];
		NSURL *nextMovieURL = [nextTrack movieLocation];
		[loader setMovieURL:nextMovieURL];
		[loader load];
=======
	if(self.didPreloading) return;
	
	NSTimeInterval duration;
	NSTimeInterval current;
	QTTime qttime = [self.playingMovie currentTime];
	if(!QTGetTimeInterval(qttime, &current)) return;
	
	duration = self.playingMovieDuration;
	
	if( current / duration > XspfQTPref.beginingPreloadPercent ) {
		self.didPreloading = YES;
		HMXSPFComponent *list = self.trackList;
		NSUInteger nextIndex = list.selectionIndex + 1;
		NSUInteger max = list.childrenCount;
		if(max <= nextIndex) return;
		
		HMXSPFComponent *nextTrack = [list childAtIndex:nextIndex];
		NSURL *nextMovieURL = nextTrack.movieLocation;
		self.loader.movieURL = nextMovieURL;
		[self.loader load];
>>>>>>> trunk:XspfQTDocument.m
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

