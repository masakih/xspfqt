//
//  XspfPlayListWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfPlayListWindowController.h"
#import "XspfDocument.h"
#import "XspfComponent.h"


@interface XspfPlayListWindowController(Private)
- (void)setObserveObject:(id)new;
@end

@implementation XspfPlayListWindowController

static NSString *const XspfQTPlayListItemType = @"XspfQTPlayListItemType";

- (id)init
{
	return [super initWithWindowNibName:@"XspfPlayList"];
}

- (void)awakeFromNib
{
	[listView setDoubleAction:@selector(changeCurrentTrack:)];
	[[self window] setReleasedWhenClosed:NO];
	
	[trackListTree addObserver:self
					forKeyPath:@"selection"
					   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
					   context:NULL];
	[self setObserveObject:[trackListTree valueForKeyPath:@"selection.self"]];
	
	[listView expandItem:[listView itemAtRow:0]];
	
//	[listView registerForDraggedTypes:[NSArray arrayWithObject:XspfQTPlayListItemType]];
}
- (void)dealloc
{
	[trackListTree removeObserver:self forKeyPath:@"selection"];
	[self setObserveObject:nil];
	
	[super dealloc];
}

- (IBAction)changeCurrentTrack:(id)sender
{
	id selections = [trackListTree selectedObjects];
	if([selections count] == 0) return;
	
	NSIndexPath *selectionIndexPath = [trackListTree selectionIndexPath];
//	NSLog(@"Selection %@", selectionIndexPath);
//	NSLog(@"Selection index %d", [selectionIndexPath indexAtPosition:1]);
	
	if([selectionIndexPath length] > 1) {
		[[self document] setPlayTrackindex:[selectionIndexPath indexAtPosition:1]];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return;
	
	unsigned short code = [theEvent keyCode];
	if(code == 49 /* space bar */) {
		[[self document] togglePlayAndPause:self];
	}
}
- (void)deleteBackward:(id)sender
{
	id selection = [[trackListTree selection] representedObject];
	[[self document] removeItem:selection];
}
- (void)deleteForward:(id)sender
{
	id selection = [[trackListTree selection] representedObject];
	[[self document] removeItem:selection];
}

- (BOOL)windowShouldClose:(id)sender
{
	[sender orderOut:self];
	
	return NO;
}
- (void)setObserveObject:(id)new
{
	if(obseveObject == new) return;
	
	[obseveObject removeObserver:self forKeyPath:@"title"];
	
	obseveObject = new;
	[obseveObject addObserver:self
				   forKeyPath:@"title"
					  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
					  context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection"]) {
		id new = [object valueForKeyPath:@"selection.self"];
		[self setObserveObject:new];
	}
	
	if([keyPath isEqualToString:@"title"]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		id old = [change objectForKey:NSKeyValueChangeOldKey];
		
		if(new == old) return;
		if([new isEqualTo:old]) return;
		
		id um = [[self document] undoManager];
		[um registerUndoWithTarget:obseveObject
						  selector:@selector(setTitle:)
							object:old];
	}
}


- (BOOL)outlineView:(NSOutlineView *)outlineView
		 writeItems:(NSArray *)items
	   toPasteboard:(NSPasteboard *)pasteboard
{
	if([items count] > 1) return NO;
	
	id item = [[items objectAtIndex:0] representedObject];
	
	if(![item isKindOfClass:[XspfComponent class]]) {
		NSLog(@"Ouch! %@", NSStringFromClass([item class]));
		return NO;
	}
	if(![item isLeaf]) return NO;
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
	if(!data) {
		NSLog(@"Could not archive.");
		return NO;
	}
	
	[pasteboard declareTypes:[NSArray arrayWithObject:XspfQTPlayListItemType]
					   owner:self];
	[pasteboard setData:data
				forType:XspfQTPlayListItemType];
	return YES;
}
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
				  validateDrop:(id <NSDraggingInfo>)info
				  proposedItem:(id)item
			proposedChildIndex:(NSInteger)index
{
	if([item isLeaf]) {
		return NSDragOperationNone;
	}
	
	id pb = [info draggingPasteboard];
	
	if(![[pb types] containsObject:XspfQTPlayListItemType]) {
		return NSDragOperationNone;
	}
	
	return NSDragOperationMove;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView
		 acceptDrop:(id <NSDraggingInfo>)info
			   item:(id)item
		 childIndex:(NSInteger)index
{
	if([item isLeaf]) {
		return NO;
	}
	
	id pb = [info draggingPasteboard];
	
	NSData *data = [pb dataForType:XspfQTPlayListItemType];
	if(!data) return NO;
	
	id newItem = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if(!newItem) return NO;
	
//	NSLog(@"new item class is %@\n%@", NSStringFromClass([newItem class]), newItem);
	[[self document] removeItem:newItem];
	
	return YES;
}

@end

@implementation XspfThowSpacebarKeyDownOutlineView
- (void)keyDown:(NSEvent *)theEvent
{
	unsigned short code = [theEvent keyCode];
	if(code == 49 /* space bar */) {
		if(_delegate && [_delegate respondsToSelector:@selector(keyDown:)]) {
			[_delegate keyDown:theEvent];
		}
	}
	
	[super keyDown:theEvent];
}

@end
