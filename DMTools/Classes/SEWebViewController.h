//
//  SEWebViewController.h
//  DM Tools
//
//  Created by hamouras on 18/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SEWebViewControllerDelegate;

@interface SEWebViewController : UIViewController<UIWebViewDelegate> {
	UIToolbar *		_toolbar;
	NSURL *			_URL;
	BOOL			_requested;
	id<SEWebViewControllerDelegate> _delegate;
}

@property (nonatomic, readonly) UIWebView * webView;
@property (nonatomic, retain) IBOutlet UIToolbar * toolbar;
@property (nonatomic, retain) NSURL * URL;
@property (nonatomic, assign) IBOutlet id<SEWebViewControllerDelegate> delegate;

- (id)initWithURL:(NSURL *)url;

@end

@protocol SEWebViewControllerDelegate <NSObject>

@optional
- (NSURL*) webViewControllerRequestURL:(SEWebViewController*)webViewController;

@end