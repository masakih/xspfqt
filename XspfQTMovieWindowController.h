//
//  XspfQTMovieWindowController.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
<<<<<<< HEAD:XspfQTMovieWindowController.h
//  Copyright 2008 masakih. All rights reserved.
//

=======
//

/*
 This source code is release under the New BSD License.
 Copyright (c) 2008-2009,2012, masakih
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
 Copyright (c) 2008-2009,2012, masakih
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

>>>>>>> trunk:XspfQTMovieWindowController.h
#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


<<<<<<< HEAD:XspfQTMovieWindowController.h
@interface XspfQTMovieWindowController : NSWindowController
=======
@interface XspfQTMovieWindowController : NSWindowController <NSWindowDelegate>
>>>>>>> trunk:XspfQTMovieWindowController.h
{
	IBOutlet QTMovieView *qtView;
	IBOutlet NSButton *playButton;
	
<<<<<<< HEAD:XspfQTMovieWindowController.h
	NSWindow *fullscreenWindow;
	NSRect normalModeSavedFrame;
	BOOL fullScreenMode;
	
	QTMovie *qtMovie;
=======
	IBOutlet NSView *controllerView;
	
	NSWindow *fullscreenWindow;
	NSRect normalModeSavedFrame;
	
#ifndef __LP64__
	BOOL _fullScreenMode;
	QTMovie *_qtMovie;
#endif
>>>>>>> trunk:XspfQTMovieWindowController.h
	
	NSPoint prevMouse;
	NSDate *prevMouseMovedDate;
	
	NSSize windowSizeWithoutQTView;
	
	BOOL isChangingFullScreen;
}
<<<<<<< HEAD:XspfQTMovieWindowController.h
=======
@property (retain)QTMovie *qtMovie;
>>>>>>> trunk:XspfQTMovieWindowController.h

- (IBAction)turnUpVolume:(id)sender;
- (IBAction)turnDownVolume:(id)sender;
- (IBAction)togglePlayAndPause:(id)sender;
- (IBAction)toggleFullScreenMode:(id)sender;
- (IBAction)forwardTagValueSecends:(id)sender;
- (IBAction)backwardTagValueSecends:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;
<<<<<<< HEAD:XspfQTMovieWindowController.h
=======
- (IBAction)gotoBeginningOrPreviousTrack:(id)sender;
>>>>>>> trunk:XspfQTMovieWindowController.h
- (IBAction)normalSize:(id)sender;
- (IBAction)halfSize:(id)sender;
- (IBAction)doubleSize:(id)sender;
- (IBAction)screenSize:(id)sender;

<<<<<<< HEAD:XspfQTMovieWindowController.h
- (void)play;
- (void)stop;

- (void)setQtMovie:(QTMovie *)qt;
- (QTMovie *)qtMovie;
=======
- (IBAction)gotoThumbnailFrame:(id)sender;

- (void)play;
- (void)stop;
>>>>>>> trunk:XspfQTMovieWindowController.h
@end

extern NSString *XspfQTMovieDidStartNotification;
extern NSString *XspfQTMovieDidPauseNotification;
