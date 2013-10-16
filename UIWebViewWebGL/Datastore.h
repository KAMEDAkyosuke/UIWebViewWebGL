//
//  Datastore.h
//  UIWebViewWebGL
//
//  Created by organlounge on 2013/10/16.
//  Copyright (c) 2013年 Nathan de Vries. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bookmark;
@interface Datastore : NSObject

+ (instancetype)sharedDatastore;

- (void)open:(NSString*)fileName;
- (void)close;

#pragma mark - bookmark

- (NSArray*)bookmarks;
- (void)insertOrReplaceBookmark:(Bookmark*)bookmark;
- (void)deletBookmark:(Bookmark*)bookmark;

@end
