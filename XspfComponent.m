//
//  XspfComponent.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfComponent.h"


@implementation XspfComponent

+ (id)xspfComponemtWithXMLElement:(NSXMLElement *)element
{
	return [[[self alloc] initWithXMLElement:element] autorelease];
}
- (id)initWithXMLElement:(NSXMLElement *)element
{
	[super init];
	[self doesNotRecognizeSelector:_cmd];
	
	[self release];
	
	return nil;
}

- (QTMovie *)qtMovie
{
	return nil;
}
- (NSDate *)duration
{
	return nil;
}

- (NSArray *)children
{
	return nil;
}

- (void)setTitle:(NSString *)title
{
	[self doesNotRecognizeSelector:_cmd];
}
- (NSString *)title
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
- (BOOL)isSelected
{
	return isSelected;
}
- (void)select
{
	isSelected = YES;
}
- (void)deselect
{
	isSelected = NO;
}
@end
