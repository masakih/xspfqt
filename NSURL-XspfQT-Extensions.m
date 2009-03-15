//
//  NSURL-XspfQT-Extensions.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/15.
//  Copyright 2009 masakih. All rights reserved.
//

#import "NSURL-XspfQT-Extensions.h"


@implementation NSURL (XspfQT_Extensions)

- (BOOL)isEqualUsingLocalhost:(NSURL *)other
{
	if([self isEqual:other]) return YES;
	if(!other) return NO;
	
	NSString *myHost = [self host];
	NSString *otherHost = [other host];
	if(!myHost && [otherHost isEqualToString:@"localhost"]) {
		NSString *myPath = [self path];
		NSString *otherPath = [other path];
		if([myPath isEqualToString:otherPath]) return YES;
	}
	
	return NO;
}
@end
