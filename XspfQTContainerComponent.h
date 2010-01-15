//
//  XspfQTContainerComponent.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/28.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XspfQTComponent.h"


@interface XspfQTContainerComponent : XspfQTComponent
{
	NSMutableArray *_children;
	
	NSUInteger selectionIndex;
	
	XspfQTComponent *selectedComponent;
}

- (id)init;

@end
