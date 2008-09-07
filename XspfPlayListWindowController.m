//
//  XspfPlayListWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfPlayListWindowController.h"
#import "XspfDocument.h"


@interface XspfPlayListWindowController(Private)
- (void)setObserveObject:(id)new;
@end

@implementation XspfPlayListWindowController

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
	if([keyPath isEqualTo:@"selection"]) {
		id new = [object valueForKeyPath:@"selection.self"];
		[self setObserveObject:new];
	}
	
	if([keyPath isEqualTo:@"title"]) {
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
