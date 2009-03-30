//
//  XspfQTMovieLoader.m
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/14.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTMovieLoader.h"

#import "NSURL-XspfQT-Extensions.h"

@implementation XspfQTMovieLoader
+ (id)loaderWithMovieURL:(NSURL *)inMovieURL delegate:(id)inDelegate
{
	return [[[[self class] alloc] initWithMovieURL:inMovieURL delegate:inDelegate] autorelease];
}
- (id)initWithMovieURL:(NSURL *)inMovieURL delegate:(id)inDelegate
{
	self = [super init];
	if(self) {
		
		@try {
			[self setDelegate:inDelegate];
		}
		@catch (XspfQTMovieLoader *me) {
			[self autorelease];
			return nil;
		}
		[self setMovieURL:inMovieURL];
	}
	
	return self;
}

- (void)dealloc
{
	[movieURL release];
	[movie release];
	
	[super dealloc];
}

- (void)setMovieURL:(NSURL *)url
{
	if([url isEqualUsingLocalhost:movieURL]) return;
	
	[self setQTMovie:nil];
	[movieURL autorelease];
	movieURL = [url retain];
}
- (NSURL *)movieURL
{
	return movieURL;
}
- (void)setQTMovie:(QTMovie *)newMovie
{
	[movie release];
	movie = [newMovie retain];
}
- (QTMovie *)qtMovie
{
	return movie;
}

- (void)setDelegate:(id)inDelegate
{
	if(inDelegate && ![inDelegate respondsToSelector:@selector(setQTMovie:)]) {
		NSLog(@"Delegate should be respond to selector setQTMovie:");
		@throw self;
	}
	
	delegate = inDelegate;
}
- (id)delegate
{
	return delegate;
}

- (void)load
{
	QTMovie *newMovie = nil;
	
	if(movie) return;
		
	if(![QTMovie canInitWithURL:movieURL]) goto finish;
	
	NSError *error = nil;
	//	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
	//						   [self location], QTMovieURLAttribute,
	//						   [NSNumber numberWithBool:NO], QTMovieOpenAsyncOKAttribute,
	//						   nil];
	//	movie = [[QTMovie alloc] initWithAttributes:attrs error:&error];
	newMovie = [[QTMovie alloc] initWithURL:movieURL error:&error];
	if(error) {
		NSLog(@"%@", error);
	}
	
finish:
	[self setQTMovie:[newMovie autorelease]];
	[delegate setQTMovie:movie];
}
- (void)loadInBG
{
	[self performSelector:@selector(load) withObject:nil afterDelay:0.0];
}

@end
