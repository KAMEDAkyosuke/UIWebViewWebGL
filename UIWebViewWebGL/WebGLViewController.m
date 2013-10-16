//
//  WebGLViewController.m
//  UIWebViewWebGL
//
//  Created by organlounge on 2013/10/16.
//  Copyright (c) 2013年 Nathan de Vries. All rights reserved.
//

#import "WebGLViewController.h"

@interface UIWebView ()
- (id) _browserView;
- (void) _setWebGLEnabled:(BOOL)enable;
@end

@interface WebGLViewController ()

@end

@implementation WebGLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem =
    [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                target:self
                                                action:@selector(reload:)];

    
    id webDocumentView = [self.webView performSelector:@selector(_browserView)];
    id backingWebView = [webDocumentView performSelector:@selector(webView)];
    [backingWebView _setWebGLEnabled:YES];
    
    NSURL *url = [NSURL URLWithString:self.url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    id webDocumentView = [self.webView performSelector:@selector(_browserView)];
    id backingWebView = [webDocumentView performSelector:@selector(webView)];
    [backingWebView _setWebGLEnabled:NO];
    [webDocumentView setDelegate:nil];
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    [self.webView.layer removeAllAnimations];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reload:(id)sender
{
    [self.webView reload];
}

@end
