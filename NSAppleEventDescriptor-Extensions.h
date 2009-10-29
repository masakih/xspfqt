//
//  NSAppleEventDescriptor-Extensions.h
//
//  Created by Hori,Masaki on 06/01/25.
//  Copyright 2006 masakih. All rights reserved.
//

#import <Foundation/NSAppleEventDescriptor.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>

@interface NSAppleEventDescriptor(HMCocoaExtention)

+ (id)descriptorWithFloat:(float)aFloat;

+ (id)targetDescriptorWithApplicationIdentifier:(NSString *)identifier;
+ (id)targetDescriptorWithAppName:(NSString *)appName;

+ (id)objectSpecifierWithDesiredClass:(DescType)desiredClass
						   container:(NSAppleEventDescriptor *)container
							 keyForm:(DescType)keyForm
							 keyData:(NSAppleEventDescriptor *)keyData;

// throw HMAEDescriptorSendingNotAppleEventException, if reciever is not AppleEventType.
// reply can be NULL.
- (OSStatus)sendAppleEventWithMode:(AESendMode)mode
					timeOutInTicks:(long)timeOut
							replay:(NSAppleEventDescriptor **)reply;

@end


extern NSString *HMAEDescriptorSendingNotAppleEventException;
