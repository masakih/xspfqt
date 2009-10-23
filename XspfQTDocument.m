//
//  XspfQTDocument.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//

#import "XspfQTDocument.h"
#import "XspfQTAppDelegate.h"
#import "XspfQTPreference.h"
#import "XspfQTComponent.h"
#import "XspfQTMovieWindowController.h"
#import "XspfQTPlayListWindowController.h"
#import <QTKit/QTKit.h>

#import "NSURL-XspfQT-Extensions.h"
#import "XspfQTMovieLoader.h"
#import "XspfQTValueTransformers.h"


#pragma mark #### Global Variables ####
/********* Global variables *******/
NSString *XspfQTDocumentWillCloseNotification = @"XspfQTDocumentWillCloseNotification";

/**********************************/

@interface XspfQTDocument (Private)
- (void)setPlaylist:(XspfQTComponent *)newList;
- (XspfQTComponent *)playlist;
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

- (id)init
{
	self = [super init];
	if(self) {
		loader = [[XspfQTMovieLoader loaderWithMovieURL:nil delegate:nil] retain];
		
		preloadingTimer = [NSTimer scheduledTimerWithTimeInterval:10
														   target:self
														 selector:@selector(checkPreload:)
														 userInfo:nil
														  repeats:YES];
	}
	
	return self;
}
- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
	[self init];
	
	id newPlaylist = [XspfQTComponent xspfPlaylist];
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
	
	NSString *xmlElem;
	xmlElem = [NSString stringWithFormat:@"<track><location>%@</location></track>",
			   [absoluteURL absoluteString]];
	
	NSError *error = nil;
	id new = [XspfQTComponent xspfComponentWithXMLElementString:xmlElem
														  error:&error];
	if(error) {
		NSLog(@"%@", error);
		if(outError) {
			*outError = error;
		}
		return NO;
	}
	
	id pl = [XspfQTComponent xspfPlaylist];
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
	id pl = [XspfQTComponent xspfComponemtWithXMLElement:root];
	if(!pl) {
		NSLog(@"Can not create XspfQTComponent.");
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
	
	[preloadingTimer invalidate];
	
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
- (IBAction)setThumnailFrame:(id)sender
{
	XspfQTComponent *currentTrack = [[self trackList] currentTrack];
	QTTime currentQTTime = [playingMovie currentTime];
	
	NSTimeInterval currentTI;
	QTGetTimeInterval(currentQTTime, &currentTI);
	
	XspfQTComponent *prevThumnailTrack = [playlist thumnailTrack];
	NSTimeInterval ti = [playlist thumnailTimeIntarval];
	
	[playlist setThumnailComponent:currentTrack timeIntarval:currentTI];
	
	id undo = [self undoManager];
	if(prevThumnailTrack) {
		[[undo prepareWithInvocationTarget:playlist] setThumnailComponent:prevThumnailTrack timeIntarval:ti];
		[undo setActionName:NSLocalizedString(@"Change Thumnail frame.", @"Undo Action Name Change Thumnail frame")];
	} else {
		[[undo prepareWithInvocationTarget:playlist] removeThumnailFrame];
		[undo setActionName:NSLocalizedString(@"Add Thumnail frame.", @"Undo Action Name Add Thumnail frame")];
	}
}
- (IBAction)removeThumail:(id)sender
{
	XspfQTComponent *prevThumnailTrack = [playlist thumnailTrack];
	NSTimeInterval ti = [playlist thumnailTimeIntarval];
	
	[playlist removeThumnailFrame];
	
	if(prevThumnailTrack) {
		id undo = [self undoManager];
		[[undo prepareWithInvocationTarget:playlist] setThumnailComponent:prevThumnailTrack timeIntarval:ti];
		[undo setActionName:NSLocalizedString(@"Remove Thumnail frame.", @"Undo Action Name Remove Thumnail frame")];
	}
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if(action == @selector(removeThumail:)) {
		XspfQTComponent *component = [playlist thumnailTrack];
		if(!component) return NO;
	}
	
	return YES;
}

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
	NSString *xmlElem;
	xmlElem = [NSString stringWithFormat:@"<track><location>%@</location></track>",
			   [url absoluteString]];
	
	NSError *error = nil;
	id new = [XspfQTComponent xspfComponentWithXMLElementString:xmlElem
														  error:&error];
	if(error) {
		NSLog(@"%@", error);
		@throw self;
	}
	
	if(!new) {
		@throw self;
	}
	
	[self insertComponent:new atIndex:index];
}
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
- (void)moveComponent:(XspfQTComponent *)item toIndex:(NSUInteger)index
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
		XspfQTComponent *list = [self trackList];
		unsigned nextIndex = [list selectionIndex] + 1;
		unsigned max = [list childrenCount];
		if(max <= nextIndex) return;
		
		XspfQTComponent *nextTrack = [list childAtIndex:nextIndex];
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

