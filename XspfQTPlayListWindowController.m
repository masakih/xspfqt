//
//  XspfQTPlayListWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfQTPlayListWindowController.h"
#import "XspfQTDocument.h"
#import "XspfQTComponent.h"


@interface XspfQTPlayListWindowController(Private)
- (void)setObserveObject:(id)new;

- (void)insertItem:(id)item atIndex:(NSUInteger)index;
- (void)removeItem:(id)item;
- (void)moveItem:(id)item toIndex:(NSUInteger)index;
- (void)insertItemFromURL:(id)item atIndex:(NSUInteger)index;
@end

@implementation XspfQTPlayListWindowController

#pragma mark ### Static variables ###
static NSString *const XspfQTPlayListItemType = @"XspfQTPlayListItemType";

static NSString *const XspfQTTitleKey = @"title";

- (id)init
{
	return [super initWithWindowNibName:@"XspfQTPlayList"];
}
- (void)dealloc
{
	[trackListTree removeObserver:self forKeyPath:@"selection"];
	[self setObserveObject:nil];
	
	[super dealloc];
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
	
	[listView registerForDraggedTypes:[NSArray arrayWithObjects:
									   XspfQTPlayListItemType,
									   NSFilenamesPboardType,
									   NSURLPboardType,
									   nil]];
}

#pragma mark ### Actions ###
- (IBAction)changeCurrentTrack:(id)sender
{
	id selections = [trackListTree selectedObjects];
	if([selections count] == 0) return;
	
	NSIndexPath *selectionIndexPath = [trackListTree selectionIndexPath];
	
	if([selectionIndexPath length] > 1) {
		[[[self document] trackList] setSelectionIndex:[selectionIndexPath indexAtPosition:1]];
	}
}
- (IBAction)delete:(id)sender
{
	id selection = [trackListTree valueForKeyPath:@"selection.self"];
	[self removeItem:selection];
}
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return;
	
	unsigned short code = [theEvent keyCode];
	if(code == 49 /* space bar */) {
		[[self document] togglePlayAndPause:self];
	}
	if(code == 51 /* delete key */) {
		[self delete:self];
	}
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if([menuItem action] == @selector(delete:)) {
		if([[trackListTree selectedObjects] count] == 0) {
			return NO;
		}
		if(![[trackListTree valueForKeyPath:@"selection.isLeaf"] boolValue]) {
			return NO;
		}
	}
	
	return YES;
}

#pragma mark ### NSWindow Delegate ###
- (BOOL)windowShouldClose:(id)sender
{
	[sender orderOut:self];
	
	return NO;
}

#pragma mark ### KVO & KVC ###
- (void)setObserveObject:(id)new
{
	if(observedObject == new) return;
	
	[observedObject removeObserver:self forKeyPath:XspfQTTitleKey];
	
	observedObject = new;
	[observedObject addObserver:self
				   forKeyPath:XspfQTTitleKey
					  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
					  context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection"]) {
		id new = [object valueForKeyPath:@"selection.self"];
		[self setObserveObject:new];
	}
	
	if([keyPath isEqualToString:XspfQTTitleKey]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		id old = [change objectForKey:NSKeyValueChangeOldKey];
		
		if(new == old) return;
		if([new isEqualTo:old]) return;
		
		id um = [[self document] undoManager];
		[um registerUndoWithTarget:observedObject
						  selector:@selector(setTitle:)
							object:old];
	}
}

#pragma mark ### DataStructure Operations ###
- (void)insertItemFromURL:(id)item atIndex:(NSUInteger)index
{
	id doc = [self document];
	[doc insertComponentFromURL:item atIndex:index];
}
- (void)insertItem:(id)item atIndex:(NSUInteger)index
{
	id doc = [self document];
	[doc insertComponent:item atIndex:index];
}
- (void)removeItem:(id)item
{
	id doc = [self document];
	[doc removeComponent:item];
}
- (void)moveItem:(id)item toIndex:(NSUInteger)index
{
	id doc = [self document];
	[doc moveComponent:item toIndex:index];
}

- (void)insertItemURL:(NSURL *)url atIndex:(NSUInteger)index
{
	if(![QTMovie canInitWithURL:url]) {		
		@throw self;
	}
	
//	NSLog(@"URL is %@", url);
	@try {
		[self insertItemFromURL:url atIndex:index];
	}
	@catch(XspfQTDocument *doc) {
		@throw self;
	}
}
- (BOOL)canInsertItemFromPasteboard:(NSPasteboard *)pb
{
	if([[pb types] containsObject:NSFilenamesPboardType] ||
	   [[pb types] containsObject:NSURLPboardType]) {
		
		// ##### Check is playable. #####
		if([QTMovie canInitWithPasteboard:pb]) {
			return YES;
		}
	}
	
	return NO;
}
- (void)insertItemFromPasteboard:(NSPasteboard *)pb atIndex:(NSUInteger)index
{
	// check filenames.
	if([[pb types] containsObject:NSFilenamesPboardType]) {
		BOOL hasSuccesItem = NO;
		
		id plist = [pb propertyListForType:NSFilenamesPboardType];
		if(![plist isKindOfClass:[NSArray class]]) {
			@throw self;
		}
		NSEnumerator *reverse = [plist reverseObjectEnumerator];
		for(id obj in reverse) {
			NSURL *fileURL = [NSURL fileURLWithPath:obj];
			@try {
				[self insertItemURL:fileURL atIndex:index];
			}
			@catch(XspfQTPlayListWindowController *me) {
				continue;
			}
			hasSuccesItem = YES;
		}
		
		if(!hasSuccesItem) {
			@throw self;
		}
		return;
	}
	
	// check URL
	if([[pb types] containsObject:NSURLPboardType]) {
		id url = [NSURL URLFromPasteboard:pb];
		if(url) {
			[self insertItemURL:url atIndex:index];
			return;
		}
	}
	
	@throw self;
}

#pragma mark ### NSOutlineView DataSource ###
- (BOOL)outlineView:(NSOutlineView *)outlineView
		 writeItems:(NSArray *)items
	   toPasteboard:(NSPasteboard *)pasteboard
{
	if([items count] > 1) return NO;
	
	id item = [[items objectAtIndex:0] representedObject];
	
	if(![item isKindOfClass:[XspfQTComponent class]]) {
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
					   owner:nil];
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
		// ##### insert files? ##### 
		if([self canInsertItemFromPasteboard:pb]) {
			return NSDragOperationCopy;
		}
		return NSDragOperationNone;
	}
	
	if(index == -1) return NSDragOperationNone;
	
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
	
	if(index == -1) {
		index = [[[self document] trackList] childrenCount];
	}
	
	id pb = [info draggingPasteboard];
	
	NSData *data = [pb dataForType:XspfQTPlayListItemType];
	if(!data) {
		// ##### insert files? #####
		@try {
			[self insertItemFromPasteboard:pb atIndex:index];
		}
		@catch(XspfQTPlayListWindowController *me) {
			return NO;
		}
		return YES;
	}
	
	id newItem = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if(!newItem) return NO;
	
	id doc = [self document];
	NSInteger oldIndex = [[doc trackList] indexOfChild:newItem];
	
	if(oldIndex == NSNotFound) {
		// from other list.
		[self insertItem:newItem atIndex:index];
		return YES;
	}
	
	if(oldIndex == index) return YES;
	if(oldIndex < index) {
		index--;
	}
	
	// change archive to original.
	newItem = [[doc trackList] childAtIndex:oldIndex];
	
	BOOL mustSelectionChange = NO;
	if([newItem isSelected]) {
		mustSelectionChange = YES;
	}
	
	[self moveItem:newItem toIndex:index];
	
	if(mustSelectionChange) {
		[[doc trackList] setSelectionIndex:index];
	}
	
	return YES;
}

@end

@implementation XspfQTPlaylistOutlineView
- (void)keyDown:(NSEvent *)theEvent
{
	if(_delegate && [_delegate respondsToSelector:@selector(keyDown:)]) {
		[_delegate keyDown:theEvent];
	}
	
	[super keyDown:theEvent];
}
@end
