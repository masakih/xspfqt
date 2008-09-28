//
//  XspfQTComponent.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface XspfQTComponent : NSObject <NSCoding>
{
	NSString *title;
	BOOL isSelected;
	NSIndexPath *selectionIndexPath;
	
	XspfQTComponent *parent;	// not retained.
}

+ (id)xspfPlaylist;
+ (id)xspfTrackList;

+ (id)xspfComponemtWithXMLElement:(NSXMLElement *)element;
- (id)initWithXMLElement:(NSXMLElement *)element; // abstract.

- (NSXMLElement *)XMLElement; // abstract.

- (QTMovie *)qtMovie;

- (void)setTitle:(NSString *)title;
- (NSString *)title;

// selection for playing.
- (BOOL)isSelected;
- (void)select;
- (void)deselect;
- (void)setSelectionIndex:(unsigned)index;
- (BOOL)setSelectionIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)selectionIndexPath;

- (XspfQTComponent *)currentTrack;	// default self;
- (void)next;						// abstract.
- (void)previous;					// abstract.

- (void)setIsPlayed:(BOOL)state;
- (BOOL)isPlayed;

- (XspfQTComponent *)parent;
- (NSArray *)children;		// default nil.
- (unsigned)childrenCount;	// default [[self children] count].
- (NSUInteger)indexOfChild:(XspfQTComponent *)child;	// default [[self children] indexOfObject:].
- (XspfQTComponent *)childAtIndex:(NSUInteger)index;	// default [[self children] objectAtIndex:].
- (BOOL)isLeaf;				// default YES.

- (void)addChild:(XspfQTComponent *)child;	// not implemented.
- (void)removeChild:(XspfQTComponent *)child;	// not implemented.
- (void)insertChild:(XspfQTComponent *)child atIndex:(unsigned)index;	// not implemented.
- (void)removeChildAtIndex:(unsigned)index;	//not implemented.
- (void)setParent:(XspfQTComponent *)parent;	// Do not call directly. call in only -addChild: method.


@end
