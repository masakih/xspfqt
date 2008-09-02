//
//  MyDocument.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//

#import "XspfDocument.h"
#import "XspfTrackList.h"
#import "XspfMovieWindowController.h"
#import "XspfPlayListWindowController.h"

@interface XspfDocument (Private)
- (void)setTrackList:(XspfTrackList *)newList;
- (XspfTrackList *)trackList;
@end

@implementation XspfDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		    
    }
    return self;
}

- (void)makeWindowControllers
{
	playListWindowController = [[XspfPlayListWindowController alloc] init];
	[self addWindowController:playListWindowController];
	
	id movieWindowController = [[[XspfMovieWindowController alloc] init] autorelease];
	[self addWindowController:movieWindowController];
	[movieWindowController setQtMovie:[[self trackList] qtMovie]];
}
//- (NSString *)windowNibName
//{
//    // Override returning the nib file name of the document
//    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
//    return @"MyDocument";
//}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
//	[self setQtMovie:[[self trackList] qtMovie]];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
	NSError *error = nil;
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithData:data
													options:0
													  error:&error] autorelease];
	NSXMLElement *root = [d rootElement];
	
	NSArray *trackListElems;
	trackListElems = [root elementsForName:@"trackList"];
	//	NSLog(@"trackList -> %@", trackListElems);
	
	if([trackListElems count] < 1) {
		if ( outError != NULL ) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
		}
		return NO;
	}
	
	id t = [XspfTrackList xspfComponemtWithXMLElement:[trackListElems objectAtIndex:0]];
	[t setTitle:[[[self fileURL] path] lastPathComponent]];
	[self setTrackList:t];
//	NSLog(@"trackList -> %@", trackList);
	
//	[self setQtMovie:[[self trackList] qtMovie]];
	
    return YES;
}

- (void)dealloc
{
	[trackList release];
	[playListWindowController release];
	
	[super dealloc];
}
- (NSString *)displayName
{
	NSString *trackTitle = [[[self trackList] currentTrack] title];
	if(trackTitle) {
		return [NSString stringWithFormat:@"%@ - %@",
				[super displayName], trackTitle];
	}
	
	return [super displayName];
}

- (IBAction)showPlayList:(id)sender
{
	[playListWindowController showWindow:self];
}

- (void)setTrackList:(XspfTrackList *)newList
{
	if(trackList == newList) return;
	
	[trackList autorelease];
	trackList = [newList retain];
}
- (XspfTrackList *)trackList
{
	return trackList;
}

- (void)setPlayTrackindex:(unsigned)index
{
	[[self trackList] setCurrentIndex:index];
}
@end

