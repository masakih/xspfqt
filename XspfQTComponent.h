//
//  XspfQTComponent.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XspfQTComponent : NSObject <NSCoding>
{
	NSString *title;
	BOOL isSelected;
	NSIndexPath *selectionIndexPath;
	
	XspfQTComponent *parent;	// not retained.
}

+ (id)xspfPlaylist;
+ (id)xspfTrackList;
+ (id)xspfTrackWithLocation:(NSURL *)location;
+ (id)xspfComponentWithXMLElementString:(NSString *)string error:(NSError **)outError;

+ (id)xspfComponemtWithXMLElement:(NSXMLElement *)element;
- (id)initWithXMLElement:(NSXMLElement *)element; // abstract.

- (NSXMLElement *)XMLElement; // abstract.

- (NSURL *)movieLocation;

- (void)setTitle:(NSString *)title;
- (NSString *)title;

- (void)setDuration:(NSDate *)duration;
- (NSDate *)duration;
@end

@interface XspfQTComponent (XspfComponentSelection)
// selection for playing.
- (BOOL)isSelected;
- (void)select;
- (void)deselect;
- (void)setSelectionIndex:(unsigned)index;
- (unsigned)selectionIndex;
- (BOOL)setSelectionIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)selectionIndexPath;

- (void)setIsPlayed:(BOOL)state;
- (BOOL)isPlayed;

- (XspfQTComponent *)currentTrack;	// default self;
- (void)next;						// abstract.
- (void)previous;					// abstract.

- (void)setCurrentTrackDuration:(NSDate *)duration;
- (NSDate *)currentTrackDuration;

@end

@interface XspfQTComponent(XspfConainerComponent)
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
- (void)moveChildFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;	//not implemented.
- (void)setParent:(XspfQTComponent *)parent;	// Do not call directly. call in only -addChild: method.
@end

@interface XspfQTComponent(XspfThumnailSupport)
- (void)setThumnailTrackNum:(NSUInteger)trackNum timeIntarval:(NSTimeInterval)timeIntarval;
- (void)setThumnailComponent:(XspfQTComponent *)item timeIntarval:(NSTimeInterval)timeIntarval;
- (XspfQTComponent *)thumnailTrack;
- (NSTimeInterval)thumnailTimeIntarval;
- (void)removeThumnailFrame;
@end

extern NSString *XspfQTXMLTrackElementName;
extern NSString *XspfQTXMLTrackListElementName;
extern NSString *XspfQTXMLPlaylistElementName;
extern NSString *XspfQTXMLTitleElementName;
extern NSString *XspfQTXMLLocationElementName;
extern NSString *XspfQTXMLDurationElementName;

extern NSString *XspfQTXMLExtensionElementName;
extern NSString *XspfQTXMLApplicationAttributeName;


extern NSString *XspfQTXMLNamespaceseURI;
extern NSString *XspfQTXMLNamespacesePrefix;
extern NSString *XspfQTXMLAliasElement;
extern NSString *XspfQTXMLThumnailElementName;
extern NSString	*XspfQTXMLThumnailTrackNumAttributeName;
extern NSString	*XspfQTXMLThumnailTimeAttributeName;

