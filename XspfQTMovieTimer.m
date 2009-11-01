//
//  XspfQTMovieTimer.m
//  XspfQT
//
//  Created by Hori, Masaki on 09/10/31.
//  Copyright 2009 masakih. All rights reserved.
//

#import "XspfQTMovieTimer.h"


@implementation XspfQTMovieTimer

- (id)init
{
	self = [super init];
	
	documents = [[NSMutableArray alloc] init];
	movieWindowControllers = [[NSMutableDictionary alloc] init];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(documentWillClose:)
			   name:XspfQTDocumentWillCloseNotification
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(movieDidStart:)
			   name:XspfQTMovieDidStartNotification
			 object:nil];
	[nc addObserver:self
		   selector:@selector(movieDidPause:)
			   name:XspfQTMovieDidPauseNotification
			 object:nil];
	
	return self;
}

+ (id)movieTimer
{
	return [[[self alloc] init] autorelease];
}
- (void)dealloc
{
	[documents release];
	[movieWindowControllers release];
	[timer invalidate]; timer = nil;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)makeTimer
{
	@synchronized(self) {
		if(timer) return;
		timer = [NSTimer scheduledTimerWithTimeInterval:0.5
												 target:self
											   selector:@selector(fire:)
											   userInfo:NULL
												repeats:YES];
		[timer retain];
	}
}
- (void)dropTimer
{
	@synchronized(self) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
}

- (void)enableFireing:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		if([documents containsObject:doc]) return;
		
		[documents addObject:doc];
		if([pausedDocuments containsObject:doc]) {
			[pausedDocuments removeObject:doc];
		}
	}
	
	[self makeTimer];
}
- (void)disableFireing:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		if([pausedDocuments containsObject:doc]) return;
		
		[pausedDocuments addObject:doc];
		if([documents containsObject:doc]) {
			[documents removeObject:doc];
		}
		
		if([documents count] == 0) {
			[self dropTimer];
		}
	}
}
- (void)addDocument:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		if([documents containsObject:doc]) return;
		if([pausedDocuments containsObject:doc]) return;
		
		[documents addObject:doc];
		
		NSArray *wControlers = [doc windowControllers];
		for(id w in wControlers) {
			if([w isKindOfClass:[XspfQTMovieWindowController class]]) {
				[movieWindowControllers setObject:w forKey:[NSValue valueWithPointer:doc]];
			}
		}
	}
	
	[self makeTimer];
}
- (void)removeDocument:(XspfQTDocument *)doc
{
	@synchronized(documents) {
		[movieWindowControllers removeObjectForKey:[NSValue valueWithPointer:doc]];
		
		if([documents containsObject:doc]) {
			[documents removeObject:doc];
		}
		if([pausedDocuments containsObject:doc]) {
			[documents removeObject:doc];
		}
		
		if([documents count] == 0) {
			[self dropTimer];
		}
	}
}

- (void)put:(XspfQTDocument *)doc
{
	[self addDocument:doc];
}

- (void)documentWillClose:(id)notification
{
	id doc = [notification object];
	[self removeDocument:doc];
}

- (void)movieDidStart:(id)notification
{
	id wc = [notification object];
	XspfQTDocument *doc = [wc document];
	[self enableFireing:doc];
}
- (void)movieDidPause:(id)notification
{
	id wc = [notification object];
	XspfQTDocument *doc = [wc document];
	[self disableFireing:doc];
}

- (void)fire:(id)t
{
	XspfQTDocument *doc;
	XspfQTMovieWindowController *wc;
	
	@synchronized(documents) {
		for(doc in documents) {
			wc = [movieWindowControllers objectForKey:[NSValue valueWithPointer:doc]];
			
			[doc checkPreload:t];
			[wc updateTimeIfNeeded:t];
		}
	}
}

@end
