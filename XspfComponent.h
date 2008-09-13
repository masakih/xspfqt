//
//  XspfComponent.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface XspfComponent : NSObject <NSCoding>
{
	NSString *title;
	BOOL isSelected;
	NSIndexPath *selectionIndexPath;
	
	XspfComponent *parent;	// not retained.
}

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

- (XspfComponent *)currentTrack;	// default self;
- (void)next;						// abstract.
- (void)previous;					// abstract.

- (void)setIsPlayed:(BOOL)state;
- (BOOL)isPlayed;

- (XspfComponent *)parent;
- (NSArray *)children;		// default nil.
- (unsigned)childrenCount;	// default [[self children] count].
- (BOOL)isLeaf;				// default YES.

- (void)addChild:(XspfComponent *)child;	// not implemented.
- (void)removeChild:(XspfComponent *)child;	// not implemented.
- (void)insertChild:(XspfComponent *)child atIndex:(unsigned)index;	// not implemented.
- (void)removeChildAtIndex:(unsigned)index;	//not implemented.
- (void)setParent:(XspfComponent *)parent;	// Do not call directly. call in only -addChild: method.


@end
