//
//  XspfPlayListWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfPlayListWindowController.h"
#import "XspfDocument.h"


@implementation XspfPlayListWindowController

- (id)init
{
	return [super initWithWindowNibName:@"XspfPlayList"];
}

- (void)awakeFromNib
{
	[listView setDoubleAction:@selector(changeCurrentTrack:)];
//	[[self window] setReleasedWhenClosed:NO];
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
