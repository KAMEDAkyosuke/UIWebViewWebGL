//
//  WebGLViewController.h
//  UIWebViewWebGL
//
//  Created by organlounge on 2013/10/16.
//  Copyright (c) 2013年 Nathan de Vries. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebGLViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, copy) NSString *url;

@end
