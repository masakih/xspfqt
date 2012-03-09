//
//  XspfSpotlighterHelper.h
//  XspfSpotlighterHelper
//
//  Created by Hori,Masaki on 11/06/29.
//  Copyright 2011 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol XspfQTSpotlightIndexerProtocol
- (NSDictionary *)dataFromURL:(NSURL *)url;
@end

@interface XspfSpotlighterHelper : NSObject <XspfQTSpotlightIndexerProtocol>
@end
