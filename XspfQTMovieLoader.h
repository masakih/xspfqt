//
//  XspfQTMovieLoader.h
//  XspfQT
//
//  Created by Hori,Masaki on 09/03/14.
//  Copyright 2009 masakih. All rights reserved.
//

#import <QTKit/QTKit.h>


@interface XspfQTMovieLoader : NSObject
{
	id delegate;
	NSURL *movieURL;
	QTMovie *movie;
}

+ (id)loaderWithMovieURL:(NSURL *)movieURL delegate:(id)delegate;
- (id)initWithMovieURL:(NSURL *)movieURL delegate:(id)delegate;

- (void)setMovieURL:(NSURL *)url;
- (NSURL *)movieURL;
- (QTMovie *)qtMovie;

// throw self if delegate dose not respond setQTMovie:.
- (void)setDelegate:(id)delegate;
- (id)delegate;

- (void)load;
- (void)loadInBG;	// did finish load, it sends setQTMovie: to delegate.

@end

@interface NSObject (XspfQTMovieLoaderDelegate)
- (void)setQTMovie:(QTMovie *)movie;
@end
