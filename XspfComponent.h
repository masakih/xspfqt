//
//  XspfComponent.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface XspfComponent : NSObject
{
	BOOL isSelected;
}

+ (id)xspfComponemtWithXMLElement:(NSXMLElement *)element;
- (id)initWithXMLElement:(NSXMLElement *)element;

- (QTMovie *)qtMovie;

- (void)setTitle:(NSString *)title;
- (NSString *)title;
- (BOOL)isSelected;
- (void)select;
- (void)deselect;
- (void)setIsPlayed:(BOOL)state;
- (BOOL)isPlayed;
@end
