#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>

#import <Foundation/Foundation.h>

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

@protocol XspfQTSpotlightIndexerProtocol
- (NSDictionary *)dataFromURL:(NSURL *)url;
@end



Boolean setAttributeWithRegisteredName( CFMutableDictionaryRef attributes,
									   CFStringRef pathToFile,
									   NSString *registeredName)
{
	id pool = [[NSAutoreleasePool alloc] init];
	
//	NSLog(@"Current -> %@\n", attributes);
	
	NSConnection *con = [NSConnection connectionWithRegisteredName:registeredName
															  host:nil];
	if(!con) {
		NSLog(@"Can not get connection named %@", registeredName);
		return YES;
	}
	
	id proxy = [con rootProxy];
	if(!proxy) {
		NSLog(@"Can not get root proxy.");
		return FALSE;
	}
	
	[proxy setProtocolForProxy:@protocol(XspfQTSpotlightIndexerProtocol)];
	
	NSURL *urlForFile = [NSURL fileURLWithPath:(NSString *)pathToFile];
	NSDictionary *dict = [proxy dataFromURL:urlForFile];
	if(!dict) {
		NSLog(@"Can not get data");
		return FALSE;
	}
	
//	NSLog(@"Getting data -> %@", dict);
	[(NSMutableDictionary *)attributes addEntriesFromDictionary:dict];
	
	[pool release];
	return TRUE;
fail:
	
	[pool release];
	return FALSE;
}

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
	
	Boolean res01 = setAttributeWithRegisteredName(attributes, pathToFile, @"XspfQTSpotlightIndexer");
	Boolean res02 = setAttributeWithRegisteredName(attributes, pathToFile, @"XspfManagerSpotlightIndexer");
	CFDictionarySetValue(attributes, @"com_masaki_xspf_duration", kCFNull);
	CFDictionarySetValue(attributes, @"com_masaki_xspf_movieNumber", kCFNull);
	CFDictionarySetValue(attributes, @"com_masaki_xspf_subtitle", kCFNull);
	
	
	
	return res01 || res02;
}
