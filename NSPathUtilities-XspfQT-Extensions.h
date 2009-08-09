//
//  NSPathUtilities-XspfQT-Extensions.h
//  XspfQT
//
//  Created by Hori,Masaki on 09/07/26.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (XspfQT_Extensions)
- (NSData *)aliasData;
@end

@interface NSData (XspfQT_Extensions)
- (NSString *)resolvedPath;
@end
