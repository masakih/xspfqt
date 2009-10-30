//
//  NSAppleEventDescriptor-Extensions.m
//
//  Created by Hori,Masaki on 06/01/25.
//  Copyright 2006 masakih. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "NSAppleEventDescriptor-Extensions.h"

NSString *HMAEDescriptorSendingNotAppleEventException = @"HMAEDescriptorSendingNotAppleEventException";
static NSString *HMAEDesNotAEExceptionResonFormat = @"send method shuld be call AppleEventDecripor."
														  @"but self is %@.";

@implementation NSAppleEventDescriptor(HMCocoaExtention)

+ (id)descriptorWithFloat:(float)aFloat
{
	return [NSAppleEventDescriptor descriptorWithDescriptorType:typeShortFloat
														  bytes:&aFloat
														 length:sizeof(aFloat)];
}

+ (id)targetDescriptorWithApplicationIdentifier:(NSString *)identifier
{
	const char *bundleIdentifierStr;
	
	bundleIdentifierStr = [identifier UTF8String];
	
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplicationBundleID
                                                                bytes:bundleIdentifierStr
                                                               length:strlen(bundleIdentifierStr)];
}
+ (id)targetDescriptorWithAppName:(NSString *)appName
{
	NSString *path;
	NSBundle *bundle;
	NSString *bundleIdentifier;
	
	path = [[NSWorkspace sharedWorkspace] fullPathForApplication:appName];
    bundle = [NSBundle bundleWithPath:path];
    bundleIdentifier = [bundle bundleIdentifier];
    
	return [self targetDescriptorWithApplicationIdentifier:bundleIdentifier];
}

+(id)objectSpecifierWithDesiredClass:(DescType)desiredClass
						   container:(NSAppleEventDescriptor *)container
							 keyForm:(DescType)keyForm
							 keyData:(NSAppleEventDescriptor *)keyData
{
	AEDesc objectSpecifier;
	
	OSStatus err;
	
	if(!keyData) return nil;
	if(!container) {
		container = [NSAppleEventDescriptor nullDescriptor];
	}
	
	
	err = CreateObjSpecifier( desiredClass,
							  (AEDesc *)[container aeDesc],
							  keyForm,
							  (AEDesc *)[keyData  aeDesc],
							  NO,
							  &objectSpecifier );
	
	if( err != noErr ) return nil;
	
	return [[[[self class] alloc] initWithAEDescNoCopy:&objectSpecifier] autorelease];
}

+ (NSAppleEventDescriptor *)appleEventWithEventClass:(AEEventClass)eventClass
											 eventID:(AEEventID)eventID
									targetDescriptor:(NSAppleEventDescriptor *)targetDescriptor
{
	return [self appleEventWithEventClass:eventClass
								  eventID:eventID
						 targetDescriptor:targetDescriptor
								 returnID:kAutoGenerateReturnID
							transactionID:kAnyTransactionID];
}
+ (NSAppleEventDescriptor *)appleEventWithEventClass:(AEEventClass)eventClass
											 eventID:(AEEventID)eventID
							   applicationIdentifier:(NSString *)identifier
{
	NSAppleEventDescriptor *target;
	target = [self targetDescriptorWithApplicationIdentifier:identifier];
	if(!target) return nil;
	return [self appleEventWithEventClass:eventClass
								  eventID:eventID
						 targetDescriptor:target];
}
+ (NSAppleEventDescriptor *)appleEventWithEventClass:(AEEventClass)eventClass
											 eventID:(AEEventID)eventID
									   targetAppName:(NSString *)targetAppName
{
	NSAppleEventDescriptor *target;
	target = [self targetDescriptorWithAppName:targetAppName];
	if(!target) return nil;
	return [self appleEventWithEventClass:eventClass
								  eventID:eventID
						 targetDescriptor:target];
}

#pragma mark## Instance Method ##
- (OSStatus)sendAppleEventWithMode:(AESendMode)mode
					timeOutInTicks:(long)timeOut
							replay:(NSAppleEventDescriptor **)outReply
{
	BOOL wantReply = NO;
	AppleEvent reply;
	AppleEventPtr replyP = NULL;
	OSStatus err;
	
	if([self descriptorType] != typeAppleEvent) {
		[NSException raise:HMAEDescriptorSendingNotAppleEventException
					format:HMAEDesNotAEExceptionResonFormat, self];
	}
	
	if(outReply && ((mode & 0x3) == 0x3)) {
		wantReply = YES;
		replyP = &reply;
	}
	
	err = AESendMessage([self aeDesc], replyP, mode, timeOut);
	if(err != noErr) return err;
	
	if(wantReply) {
		*outReply = [[[[self class] allocWithZone:[self zone]] initWithAEDescNoCopy:&reply] autorelease];
	}
	
	return err;
}

@end
