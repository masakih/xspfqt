//
//  XspfQTTrack.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTTrack.h"

@interface XspfQTTrack (Private)
- (void)setSavedDateWithQTTime:(QTTime)qttime;
- (NSDate *)duration;
@end

@implementation XspfQTTrack
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:@"location"];
	if(!elems || [elems count] == 0) {
		[self release];
		return nil;
	}
	
	NSString *loc = [[elems objectAtIndex:0] stringValue];
	[self setLocationString:loc];
	
	NSString *t;
	elems = [element elementsForName:@"title"];
	if(!elems || [elems count] == 0) {
		t = [[self locationString] lastPathComponent];
		t = [t stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	} else {
		t = [[elems objectAtIndex:0] stringValue];
	}
	[self setTitle:t];
	
	elems = [element elementsForName:@"duration"];
	if(elems && [elems count] != 0) {
		t = [[elems objectAtIndex:0] stringValue];
		NSTimeInterval ti = [t doubleValue] / 1000;
		QTTime q = QTMakeTimeWithTimeInterval(ti);
		[self setSavedDateWithQTTime:q];
	}
	
	return self;
}
- (void)dealloc
{
	[location release];
	[movie release];
	[savedDate release];
	
	[super dealloc];
}
- (NSXMLElement *)XMLElement
{
	id node = [NSXMLElement elementWithName:@"track"];
	
	id locElem = [NSXMLElement elementWithName:@"location" stringValue:[self locationString]];
	if(locElem) {
		[node addChild:locElem];
	}
	id titleElem = [NSXMLElement elementWithName:@"title" stringValue:[self title]];
	if(titleElem) {
		[node addChild:titleElem];
	}
	
	id d = [self duration];
	if(d) {
		NSTimeInterval t = [d timeIntervalSince1970];
		t += [[NSTimeZone systemTimeZone] secondsFromGMT];
		unsigned long long scaledT = (unsigned long long)t;
		scaledT *= 1000;
		id durationElem = [NSXMLElement elementWithName:@"duration"
											stringValue:[NSString stringWithFormat:@"%qu", scaledT]];
		if(durationElem) {
			[node addChild:durationElem];
		}
	}
	
	return node;
}
- (void)setLocation:(NSURL *)loc
{
	if(location && ![location isKindOfClass:[NSURL class]]) return;
	if(location == loc) return;
	if([location isEqualTo:loc]) return;
	
	[location autorelease];
	location = [loc retain];
}
- (NSURL *)location
{
	return location;
}
- (void)setLocationString:(NSString *)loc
{
	[self setLocation:[NSURL URLWithString:loc]];
}
- (NSString *)locationString
{
	NSString *str = [[self location] absoluteString];
	
	return [str stringByReplacingOccurrencesOfString:@"//localhost/"
										  withString:@"///"];
}

- (void)setSavedDateWithQTTime:(QTTime)qttime
{
	id t = [NSValueTransformer valueTransformerForName:@"XspfQTTimeDateTransformer"];
	savedDate = [[t transformedValue:[NSValue valueWithQTTime:qttime]] retain];
}
- (NSDate *)savedDate
{
	return savedDate;
}
- (NSDate *)duration
{
	if(savedDate) return savedDate;
	
	if(!movie) return nil;
	
	[self setSavedDateWithQTTime:[movie duration]];
	return [self savedDate];
}

- (QTMovie *)qtMovie
{
	if(movie) {
		[[self class] cancelPreviousPerformRequestsWithTarget:self];
		return movie;
	}
	if(![QTMovie canInitWithURL:[self location]]) return nil;
	
	[NSTimer scheduledTimerWithTimeInterval:0.05
									 target:self
								   selector:@selector(listeningLoadState:)
								   userInfo:NULL
									repeats:YES];
	
	NSError *error = nil;
//	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
//						   [self location], QTMovieURLAttribute,
//						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
//						   nil];
//	movie = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	movie = [[QTMovie alloc] initWithURL:[self location] error:&error];
	if(error) {
		NSLog(@"%@", error);
		return nil;
	}
	if(!movie) {
		return nil;
	}
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(notifee:)
				   name:QTMovieRateDidChangeNotification
				 object:movie];
		[nc addObserver:self
			   selector:@selector(movieLoadStateDidChangeNotification:)
				   name:QTMovieLoadStateDidChangeNotification
				 object:movie];
	}
	
	[self willChangeValueForKey:@"duration"];
	[self didChangeValueForKey:@"duration"];
	
	return movie;
}
- (void)setIsPlayed:(BOOL)state
{
	isPlayed = state;
}
- (BOOL)isPlayed
{
	return isPlayed;
}
- (void)next
{
	[[self parent] next];
}
- (void)previous
{
	[[self parent] previous];
}

- (void)deselect
{
	[movie stop];
	[self performSelector:@selector(purgeQTMovie)
			   withObject:nil
			   afterDelay:4.5];
	[super deselect];
}
- (void)purgeQTMovie
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self
				  name:nil
				object:movie];
	
//	NSLog(@"Purge! retain count is %u", [movie retainCount]);
	
	[movie release];
	movie = nil;
}

- (void)notifee:(id)notification
{
//	NSLog(@"Notifed: name -> (%@)\ndict -> (%@)", [notification name], [notification userInfo]);
	
	NSNumber *rateValue = [[notification userInfo] objectForKey:QTMovieRateDidChangeNotificationParameter];
	if(rateValue) {
		float rate = [rateValue floatValue];
		if(rate == 0) {
			[self setIsPlayed:NO];
		} else {
			[self setIsPlayed:YES];
		}
	}
}
- (void)movieLoadStateDidChangeNotification:(NSNotification *)notification
{
	NSLog(@"name -> %@ info -> %@", [notification name], [notification userInfo]);
}
- (void)listeningLoadState:(NSTimer *)timer
{
	static long prevState = 0;
	
	if(!movie) return;
	
	long state = [[movie attributeForKey:QTMovieLoadStateAttribute] longValue];
	
	if(prevState == state) return;
	
	switch(state) {
		case QTMovieLoadStateError:
			NSLog(@"Load Error!!!");
			goto end;
			break;
		case QTMovieLoadStateLoading:
			NSLog(@"Loading started.");
			break;
		case QTMovieLoadStateLoaded:
			NSLog(@"it's safe to query movie properties");
			break;
		case QTMovieLoadStatePlayable:
			NSLog(@" the movie has loaded enough media data to begin playing");
			break;
		case QTMovieLoadStatePlaythroughOK:
			NSLog(@"the movie has loaded enough media data to play through to the end");
			break;
		case QTMovieLoadStateComplete:
			NSLog(@"the movie has loaded completely");
			goto end;
			break;
		default:
			NSLog(@"state is %ld", state);
			break;
	}
	
	prevState = state;
	
	return;
	
end: {
	[timer invalidate];
}
}

- (BOOL)isEqual:(id)other
{
	if(![super isEqual:other]) return NO;
	if(![[self locationString] isEqual:[other locationString]]) return NO;
	
	return YES;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Title:(%@)\nLocation:(%@)",
			[self title], [self location]];
}
@end
