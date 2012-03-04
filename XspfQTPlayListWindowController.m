//
//  XspfQTPlayListWindowController.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2008-2010,2012, masakih
 All rights reserved.
 
 ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に
 限り、再頒布および使用が許可されます。
 
 1, ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含
 めること。
 2, バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表
 示、本条件一覧、および下記免責条項を含めること。
 3, 書面による特別の許可なしに、本ソフトウェアから派生した製品の宣伝または販売促進に、
 コントリビューターの名前を使用してはならない。
 本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、
 明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証
 も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューター
 も、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか
 厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する
 可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用
 サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定
 されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害につい
 て、一切責任を負わないものとします。
 -------------------------------------------------------------------
 Copyright (c) 2008-2010,2012, masakih
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1, Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2, Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.
 3, The names of its contributors may be used to endorse or promote
    products derived from this software without specific prior
    written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#import "XspfQTPlayListWindowController.h"
#import "XspfQTDocument.h"
#import "HMXSPFComponent.h"

#import "BSSUtil.h"

@interface XspfQTPlayListWindowController()
@property (readonly) XspfQTDocument *qtDocumnet;

@property (assign) id observedObject;
@end

@interface XspfQTPlayListWindowController(Private)

- (NSString *)clickedMoviePath;

- (void)insertItem:(id)item atIndex:(NSUInteger)index;
- (void)removeItem:(id)item;
- (void)moveItem:(id)item toIndex:(NSUInteger)index;
- (void)insertItemFromURL:(id)item atIndex:(NSUInteger)index;
@end

@implementation XspfQTPlayListWindowController
@synthesize observedObject = _observedObject;

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
	self.observedObject = nil;
	
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
	self.observedObject = [trackListTree valueForKeyPath:@"selection.self"];
	
	[listView expandItem:[listView itemAtRow:0]];
	
	[listView registerForDraggedTypes:[NSArray arrayWithObjects:
									   XspfQTPlayListItemType,
									   NSFilenamesPboardType,
									   NSURLPboardType,
									   nil]];
}

- (XspfQTDocument *)qtDocumnet
{
	return (XspfQTDocument *)self.document;
}

#pragma mark ### Actions ###
- (IBAction)changeCurrentTrack:(id)sender
{
	id selections = [trackListTree selectedObjects];
	if([selections count] == 0) return;
	
	NSIndexPath *selectionIndexPath = [trackListTree selectionIndexPath];
	
	if([selectionIndexPath length] > 1) {
		[self.qtDocumnet.trackList setSelectionIndex:[selectionIndexPath indexAtPosition:1]];
	}
}
- (IBAction)delete:(id)sender
{
	id selection = [trackListTree valueForKeyPath:@"selection.self"];
	[self removeItem:selection];
}	
- (IBAction)showInFinder:(id)sender
{
	NSString *path = [self clickedMoviePath];
	if(path) {
		openInFinderWithPath(path);
	}
}
- (IBAction)showInformationInFinder:(id)sender
{
	NSString *path = [self clickedMoviePath];
	if(path) {
		openInfomationInFinderWithPath(path);
	}
}
- (IBAction)showHideWindow:(id)sender
{
	NSWindow *window = [self window];
	if([window isVisible]) {
		[window performClose:sender];
	} else {
		[self showWindow:self];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent isARepeat]) return;
	
	NSString *charactor = [theEvent charactersIgnoringModifiers];
	if([charactor length] == 0) return;
	
	unichar uc = [charactor characterAtIndex:0];
	switch(uc) {
		case ' ':
			[NSApp sendAction:@selector(togglePlayAndPause:) to:nil from:nil];
			break;
		case NSDeleteCharacter:
			[self delete:self];
			break;
	}
}
- (NSString *)clickedMoviePath
{
	int row = [listView clickedRow];
	id item = [listView itemAtRow:row];
	if(!item) return nil;
	
	NSURL *location = [[item representedObject] movieLocation];
	NSString *result =  [location path];
	
	return result;
}

#pragma mark ### NSMenu valivation ###
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	if(action == @selector(delete:)) {
		if([[trackListTree selectedObjects] count] == 0) {
			return NO;
		}
		if(![[trackListTree valueForKeyPath:@"selection.isLeaf"] boolValue]) {
			return NO;
		}
	}
	if(action == @selector(showInFinder:) || action == @selector(showInformationInFinder:)) {
		NSString *path = [self clickedMoviePath];
		if(!path) return NO;
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
- (void)setObservedObject:(id)new
{
	if(_observedObject == new) return;
	
	[_observedObject removeObserver:self forKeyPath:XspfQTTitleKey];
	
	_observedObject = new;
	[_observedObject addObserver:self
				   forKeyPath:XspfQTTitleKey
					  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
					  context:NULL];
}
- (id)observedObject
{
	return _observedObject;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selection"]) {
		id new = [object valueForKeyPath:@"selection.self"];
		self.observedObject = new;
	}
	
	if([keyPath isEqualToString:XspfQTTitleKey]) {
		id new = [change objectForKey:NSKeyValueChangeNewKey];
		id old = [change objectForKey:NSKeyValueChangeOldKey];
		
		if(new == old) return;
		if([new isEqualTo:old]) return;
		
		id um = [[self document] undoManager];
		[um registerUndoWithTarget:self.observedObject
						  selector:@selector(setTitle:)
							object:old];
	}
}

#pragma mark ### DataStructure Operations ###
- (void)insertItemFromURL:(id)item atIndex:(NSUInteger)index
{
	[self.qtDocumnet insertComponentFromURL:item atIndex:index];
}
- (void)insertItem:(id)item atIndex:(NSUInteger)index
{
	[self.qtDocumnet insertComponent:item atIndex:index];
}
- (void)removeItem:(id)item
{
	[self.qtDocumnet removeComponent:item];
}
- (void)moveItem:(id)item toIndex:(NSUInteger)index
{
	[self.qtDocumnet moveComponent:item toIndex:index];
}

- (void)insertItemURL:(NSURL *)url atIndex:(NSUInteger)index
{
	if(![QTMovie canInitWithURL:url]) {		
		@throw self;
	}
	
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
	
	if(![item isKindOfClass:[HMXSPFComponent class]]) {
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
		index = self.qtDocumnet.trackList.childrenCount;
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
	
	XspfQTDocument *doc = self.qtDocumnet;
	NSInteger oldIndex = [doc.trackList indexOfChild:newItem];
	
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
	newItem = [doc.trackList childAtIndex:oldIndex];
	
	BOOL mustSelectionChange = NO;
	if([newItem isSelected]) {
		mustSelectionChange = YES;
	}
	
	[self moveItem:newItem toIndex:index];
	
	if(mustSelectionChange) {
		[doc.trackList setSelectionIndex:index];
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
