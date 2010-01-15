//
//  NSPathUtilities-XspfQT-Extensions.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/07/26.
//  Copyright 2009 masakih. All rights reserved.
//

#import "NSPathUtilities-XspfQT-Extensions.h"


@implementation NSString (XspfQT_Extensions)
- (NSData *)aliasData
{
	NSData *result = nil;
	
	NSURL *url;
	FSRef ref;
	AliasHandle alias;
	SInt8 handleState;
	BOOL res;
	OSErr error;
	
	url = [NSURL fileURLWithPath:self];
	if(!url) {
		return nil;
	}
	
	res = CFURLGetFSRef((CFURLRef)url , &ref);
	if(!res) {
		return nil;
	}
	
	error = FSNewAlias(nil, &ref, &alias);
	if(error != noErr) {
		return nil;
	}
	
	handleState = HGetState((Handle)alias);
	HLock((Handle)alias);
	result = (NSData *)CFDataCreate(kCFAllocatorDefault, (const UInt8 *)*alias, GetHandleSize((Handle)alias));
	HSetState((Handle)alias, handleState);
	DisposeHandle((Handle)alias);
	
	return [result autorelease];
}
@end

@implementation NSData (XspfQT_Extensions)
- (NSString *)resolvedPath
{
	NSString *result = nil;
	
	AliasHandle alias;
	FSRef ref;
	CFURLRef url;
	SInt8 handleState;
	Boolean wasChanged = NO;
	OSErr error;
	
	alias = (AliasHandle)NewHandle([self length]);
	handleState = HGetState((Handle)alias);
	HLock((Handle)alias);
#if !__LP64__
	BlockMoveData([self bytes], *alias, [self length]);
#else
	memmove(*alias, [self bytes], [self length]);
#endif
	HSetState((Handle)alias, handleState);
	
	error = FSResolveAlias(NULL, alias, &ref, &wasChanged);
	DisposeHandle((Handle)alias);
	if(error != noErr) {
		return nil;
	}
	
	url = CFURLCreateFromFSRef(NULL, &ref);
	if(url) {
		result = (NSString *)CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
	}
	CFRelease(url);
	
	return [result autorelease];
}
	
@end
