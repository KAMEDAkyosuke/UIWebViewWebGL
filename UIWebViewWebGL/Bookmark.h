//
//  Bookmark.h
//  UIWebViewWebGL
//
//  Created by organlounge on 2013/10/16.
//  Copyright (c) 2013年 Nathan de Vries. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bookmark : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSDate *insertAt;
@property (nonatomic, strong) NSDate *updateAt;

@end
