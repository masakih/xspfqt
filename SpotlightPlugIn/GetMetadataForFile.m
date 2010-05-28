#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

#import "HMXSPFComponent.h"

#import "XspfQTValueTransformers.h"

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForURL function
  
   Implement the GetMetadataForURL function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update schema.xml and schema.strings files
   
   The schema.xml should be added whenever you need attributes displayed in 
   Finder's get info panel, or when you have custom attributes.  
   The schema.strings should be added whenever you have custom attributes. 
 
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	if(![NSThread isMainThread]) {
//		NSLog(@"there is not main thread");
//		return FALSE;
//	}
	
//	NSLog(@"QTMovie class -> %@", NSStringFromClass([QTMovie class]));
	
	NSMutableDictionary *attr = (NSMutableDictionary *)attributes;
	
	NSError *error = nil;
	NSURL *urlForFile = [NSURL fileURLWithPath:(NSString *)pathToFile];
	NSXMLDocument *d = [[[NSXMLDocument alloc] initWithContentsOfURL:(NSURL *)urlForFile
															 options:0
															   error:&error] autorelease];
	if(error) {
		NSLog(@"%@", error);
		goto fail;
	}
	NSXMLElement *root = [d rootElement];
	id playlist = [HMXSPFComponent xspfComponentWithXMLElement:root];
	if(!playlist) {
		NSLog(@"Can not create HMXSPFComponent.");
		goto fail;
	}
		
	NSArray *tracks = [[playlist childAtIndex:0] children];
	CGFloat totalDuration = 0.0;
	for(HMXSPFComponent *track in tracks) {
		totalDuration += [[track duration] timeIntervalSince1970] + [[NSTimeZone systemTimeZone] secondsFromGMT];
		
		NSURL *url = [track movieLocation];
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
							   (id)url, QTMovieURLAttribute,
							   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
							   nil];
		QTMovie *movie = [QTMovie movieWithAttributes:attrs error:nil];
		if(!movie) {
			NSLog(@"We can not create QTMovie.");
		}
	}
	[attr setObject:[NSNumber numberWithDouble:totalDuration]
			 forKey:(NSString *)kMDItemDurationSeconds];
	
	
	[pool release];
	return TRUE;
fail:
	
    [pool release];
	return FALSE;
}
