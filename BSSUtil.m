/*
 *  BSSUtil.c
 *  BSSpotlighter
 *
 *  Created by Hori,Masaki on 06/12/16.
 *  Copyright 2006 masakih. All rights reserved.
 *
 */

#import "BSSUtil.h"
#import "stdarg.h"

#import <Foundation/Foundation.h>
#import "NSAppleEventDescriptor-HMExtensions.h"


#import <AppKit/NSWorkspace.h>

NSString *BSSLogForceWrite = @"BSSLogForceWrite";

void BSSLog(NSString *format, ...)
{
	va_list ap;
	
	va_start(ap, format);
	BSSLogv(format, ap);
	va_end(ap);
}

#ifdef DEBUG
void BSSLogv(NSString *format, va_list args)
{
	NSLogv(format, args);
}
#else
void BSSLogv(NSString *format, va_list args)
{
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	if([def boolForKey:BSSLogForceWrite]) {
		NSLogv(format, args);
	}
}
#endif

OSStatus activateFinderOnlyFrontWindow()
{
	[[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
	return noErr;
}

inline static NSAppleEventDescriptor *fileDescriptor(NSString *filePath)
{
	NSAppleEventDescriptor *fileDesc;
	NSAppleEventDescriptor *fileNameDesc;
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	const char *fileURLCharP;
	
	fileURLCharP = [[fileURL absoluteString] fileSystemRepresentation];
	fileNameDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeFileURL
																  bytes:fileURLCharP
																 length:strlen(fileURLCharP)];
	
	fileDesc = [NSAppleEventDescriptor objectSpecifierWithDesiredClass:cFile
															 container:nil
															   keyForm:formName
															   keyData:fileNameDesc];
	return fileDesc;
}
OSStatus openInFinderWithPath(NSString *filePath)
{
	NSAppleEventDescriptor *ae;
	OSStatus err = noErr;
	
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kAEMiscStandards
												  eventID:kAEMakeObjectsVisible
										 targetAppName:@"Finder"];
	if(!ae) {
		BSSLog(@"Can NOT create AppleEvent.");
		return kBSSUtilCanNotCreateAppleEventErr;
	}
	
	[ae setParamDescriptor:fileDescriptor(filePath)
				forKeyword:keyDirectObject];
	
	@try {
		err = [ae sendAppleEventWithMode:kAENoReply | kAENeverInteract
						  timeOutInTicks:kAEDefaultTimeout
								  replay:NULL];
	}
	@catch (NSException *ex) {
		if(![[ex name] isEqualTo:HMAEDescriptorSendingNotAppleEventException]) {
			@throw;
		}
	}
	@finally {
		if( err != noErr ) {
			BSSLog(@"AESendMessage Error. Error NO is %d.", err );
		}
	}
	
	return activateFinderOnlyFrontWindow();
}


OSStatus openInfomationInFinderWithPath(NSString *filePath)
{
	NSAppleEventDescriptor *ae;
	OSStatus err = noErr;
	
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass
												  eventID:kAEOpenDocuments
											targetAppName:@"Finder"];
	if(!ae) {
		BSSLog(@"Can NOT create AppleEvent.");
		return kBSSUtilCanNotCreateAppleEventErr;
	}
	
	NSAppleEventDescriptor *fileInfoDesc = [NSAppleEventDescriptor
											objectSpecifierWithDesiredClass:cProperty
											container:fileDescriptor(filePath)
											keyForm:cProperty
											keyData:[NSAppleEventDescriptor descriptorWithTypeCode:cInfoWindow]];
	
	[ae setParamDescriptor:fileInfoDesc
				forKeyword:keyDirectObject];
	
	@try {
		err = [ae sendAppleEventWithMode:kAENoReply | kAENeverInteract
						  timeOutInTicks:kAEDefaultTimeout
								  replay:NULL];
	}
	@catch (NSException *ex) {
		if(![[ex name] isEqualTo:HMAEDescriptorSendingNotAppleEventException]) {
			@throw;
		}
	}
	@finally {
		if( err != noErr ) {
			BSSLog(@"AESendMessage Error. Error NO is %d.", err );
		}
	}
	
	return noErr;
}
