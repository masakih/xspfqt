//
//  MyDocument.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//

#import "XspfDocument.h"
#import "XspfComponent.h"
#import "XspfMovieWindowController.h"
#import "XspfPlayListWindowController.h"

@interface XspfDocument (Private)
- (void)setTrackList:(XspfComponent *)newList;
- (XspfComponent *)trackList;
- (NSXMLDocument *)XMLDocument;
- (NSData *)outputData;
@end

@implementation XspfDocument

NSString *XspfDocumentWillCloseNotification = @"XspfDocumentWillCloseNotification";


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
	
	movieWindowController = [[XspfMovieWindowController alloc] init];
	[movieWindowController setShouldCloseDocument:YES];
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
		
	return [self outputData];
	//
	//
	//
	
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
	if(!trackListElems || [trackListElems count] < 1) {
		if ( outError != NULL ) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
		}
		return NO;
	}
	
	id t = [XspfComponent xspfComponemtWithXMLElement:[trackListElems objectAtIndex:0]];
	if(![t title]) {
		[t setTitle:[[[self fileURL] path] lastPathComponent]];
	}
	[self setTrackList:t];
//	NSLog(@"trackList -> %@", trackList);
	
//	[self setQtMovie:[[self trackList] qtMovie]];
	
    return YES;
}

- (void)dealloc
{
	[trackList release];
	[playListWindowController release];
	[movieWindowController release];
	
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
- (void)close
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:XspfDocumentWillCloseNotification object:self];
	
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

- (void)setTrackList:(XspfComponent *)newList
{
	if(trackList == newList) return;
	
	[trackList autorelease];
	trackList = [newList retain];
}
- (XspfComponent *)trackList
{
	return trackList;
}

- (void)setPlayTrackindex:(unsigned)index
{
	[[self trackList] setSelectionIndex:index];
}

- (NSData *)outputData
{
	return [[self XMLDocument] XMLDataWithOptions:NSXMLNodePrettyPrint];
}
- (NSXMLDocument *)XMLDocument;
{
	id element = [[self trackList] XMLElement];
	
	id root = [NSXMLElement elementWithName:@"playlist"];
	[root addChild:element];
	[root addAttribute:[NSXMLNode attributeWithName:@"version"
										stringValue:@"0"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xmlns"
										stringValue:@"http://xspf.org/ns/0/"]];
	
	
	id d = [[[NSXMLDocument alloc] initWithRootElement:root] autorelease];
	[d setVersion:@"1.0"];
	[d setCharacterEncoding:@"UTF-8"];
	
	return d;
}

- (void)insertItem:(XspfComponent *)item atIndex:(NSInteger)index
{
	//
}
- (void)removeItem:(XspfComponent *)item
{
	[movieWindowController stop];
	[[self trackList] removeChild:item];
}

- (IBAction)dump:(id)sender
{	
	NSString *s = [[[NSString alloc] initWithData:[self outputData]
										 encoding:NSUTF8StringEncoding] autorelease];
	
	NSLog(@"%@", s);
}
@end

