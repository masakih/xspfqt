//
//  XspfQTDocument.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//

#import "XspfQTDocument.h"
#import "XspfQTComponent.h"
#import "XspfQTMovieWindowController.h"
#import "XspfQTPlayListWindowController.h"
#import <QTKit/QTKit.h>

@interface XspfQTDocument (Private)
- (void)setPlaylist:(XspfQTComponent *)newList;
- (XspfQTComponent *)playlist;
- (NSXMLDocument *)XMLDocument;
- (NSData *)outputData;

- (NSData *)dataFromURL:(NSURL *)url error:(NSError **)outError;
@end

@implementation XspfQTDocument

NSString *XspfQTDocumentWillCloseNotification = @"XspfQTDocumentWillCloseNotification";

- (id)initWithType:(NSString *)typeName error:(NSError **)outError
{
	[self init];
	
	id newPlaylist = [XspfQTComponent xspfPlaylist];
	if(!newPlaylist) {
		[self autorelease];
		return nil;
	}
	
	[self setPlaylist:newPlaylist];
//	NSLog(@"new playlist is (%@)%@", NSStringFromClass([[self playlist] class]), [self playlist]);
	
	return self;
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
	return [self outputData];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	*outError = nil;
	
	if(![typeName isEqualToString:@"QuickTime Movie"]
	   || ![typeName isEqualToString:@"Matroska Video"]
	   || ![typeName isEqualToString:@"DivX Media Format"]) {
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
	
	[self setFileType:@"XML Shareable Playlist Format"];
	[self setFileURL:nil];
	
	return YES;
}
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	*outError = nil;
	
	if(![typeName isEqualToString:@"XML Shareable Playlist Format"]) {
		return NO;
	}
	
	NSError *error = nil;
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithData:data
													options:0
													  error:&error] autorelease];
	if(error) {
		NSLog(@"%@", error);
		*outError = error;
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
	
//	NSLog(@"open playlist is (%@)%@", NSStringFromClass([[self playlist] class]), [self playlist]);
	
    return YES;
}

- (void)dealloc
{
	[self setPlaylist:nil];
	[playListWindowController release];
	[movieWindowController release];
	
	[super dealloc];
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

- (IBAction)togglePlayAndPause:(id)sender
{
	[movieWindowController togglePlayAndPause:sender];
}
- (IBAction)showPlayList:(id)sender
{
	[playListWindowController showWindow:self];
}

- (void)setPlaylist:(XspfQTComponent *)newList
{
	if(playlist == newList) return;
	
	[[playlist childAtIndex:0] removeObserver:self forKeyPath:@"currentTrack"];
	[playlist autorelease];
	playlist = [newList retain];
	[[playlist childAtIndex:0] addObserver:self
								forKeyPath:@"currentTrack"
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

- (void)setPlayingMovie:(QTMovie *)newMovie
{
//	NSLog(@"new movie is %@!!", newMovie);
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self
				  name:nil
				object:playingMovie];
	
	[playingMovie autorelease];
	playingMovie = newMovie;
	
	[nc addObserver:self
		   selector:@selector(notifee:)
			   name:QTMovieRateDidChangeNotification
			 object:playingMovie];
}
- (QTMovie *)playingMovie
{
//	NSLog(@"%@ is called!!", NSStringFromSelector(_cmd));
	return playingMovie;
}

- (void)loadMovie
{
	QTMovie *newMovie = nil;
	
	NSURL *location = [[self trackList] movieLocation];
	
	if(![QTMovie canInitWithURL:location]) goto finish;
	
	NSError *error = nil;
	//	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
	//						   [self location], QTMovieURLAttribute,
	//						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
	//						   nil];
	//	movie = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	newMovie = [[QTMovie alloc] initWithURL:location error:&error];
	if(error) {
		NSLog(@"%@", error);
	}
	
	QTTime qttime = [newMovie duration];
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	[[self trackList] setCurrentTrackDuration:[t transformedValue:[NSValue valueWithQTTime:qttime]]];
	
	
finish:
	[self setPlayingMovie:newMovie];
}
- (void)setPlayingTrackIndex:(unsigned)index
{
	unsigned currentIndex = [[self trackList] selectionIndex];
	if(currentIndex == index) return;
	
	[[self trackList] setSelectionIndex:index];
	
	[self performSelector:@selector(loadMovie) withObject:nil afterDelay:0.0];
//	[self loadMovie];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:@"currentTrack"]) {
		id trackList = [self trackList];
		unsigned index = [trackList selectionIndex];
		[self setPlayingTrackIndex:index];
	}
}

- (NSData *)outputData
{
	return [[self XMLDocument] XMLDataWithOptions:NSXMLNodePrettyPrint];
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
}
- (void)removeComponent:(XspfQTComponent *)item
{
	NSUInteger index = [[self trackList] indexOfChild:item];
	if(index == NSNotFound) {
		NSLog(@"Con not found item (%@)", item); 
		return;
	}
	
	id undo = [self undoManager];
	[[undo prepareWithInvocationTarget:self] insertComponent:item atIndex:index];
	[[self trackList] removeChild:item];
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

- (IBAction)dump:(id)sender
{	
	NSString *s = [[[NSString alloc] initWithData:[self outputData]
										 encoding:NSUTF8StringEncoding] autorelease];
	
	NSLog(@"%@", s);
}
@end

