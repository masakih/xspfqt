//
//  XspfQTValueTransformers.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import <QTKit/QTKit.h>

#import "XspfQTValueTransformers.h"


@implementation XspfQTTimeTransformer
+ (Class)transformedValueClass
{
	return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation
{
	return YES;
}
- (id)transformedValue:(id)value
{
	if(!value) return nil;
	
	QTTime t = [value QTTimeValue];
	NSTimeInterval res;
	
	if(!QTGetTimeInterval(t, &res)) {return nil;}
	
	return [NSNumber numberWithDouble:res];
}
- (id)reverseTransformedValue:(id)value
{
	if(!value) return nil;
	
	QTTime t = QTMakeTimeWithTimeInterval([value doubleValue]);
	
	return [NSValue valueWithQTTime:t];
}
@end

@implementation XspfQTTimeDateTransformer
+ (Class)transformedValueClass
{
	return [NSDate class];
}
+ (BOOL)allowsReverseTransformation
{
	return NO;
}
- (id)transformedValue:(id)value
{
	if(!value) return nil;
	
	QTTime t = [value QTTimeValue];
	NSTimeInterval res;
	
	if(!QTGetTimeInterval(t, &res)) {return nil;}
	
	res -= [[NSTimeZone systemTimeZone] secondsFromGMT];
	
	return [NSDate dateWithTimeIntervalSince1970:res];
}
@end
