//
//  SEWebViewController.m
//  DM Tools
//
//  Created by hamouras on 18/08/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import "SEWebViewController.h"

@implementation SEWebViewController

@dynamic webView;
@synthesize toolbar = _toolbar;
@synthesize URL = _URL;
@synthesize delegate = _delegate;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithURL:(NSURL *)url
{
    if ((self = [super initWithNibName:@"SEWebViewController"
								bundle:nil]))
	{
		_URL = [url retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	if ([[UIDevice currentDevice] isIPad])
		self.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
	[self setToolbarItems:_toolbar.items
				 animated:YES];
	self.navigationController.toolbarHidden = NO;
	
	if( _delegate
	   && [_delegate respondsToSelector:@selector(webViewControllerRequestURL:)] )
		self.URL = [_delegate webViewControllerRequestURL:self];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:_URL];
	[self.webView loadRequest:request];
	_requested = YES;
}

- (void) updateOrientation
{
	UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	switch (toInterfaceOrientation)
	{
		case UIDeviceOrientationPortrait:
			[self.webView stringByEvaluatingJavaScriptFromString:@"window.__defineGetter__('orientation',function(){return 0;});window.onorientationchange();"];
			break;
		case UIDeviceOrientationLandscapeLeft:
			[self.webView stringByEvaluatingJavaScriptFromString:@"window.__defineGetter__('orientation',function(){return 90;});window.onorientationchange();"];
			break;
		case UIDeviceOrientationLandscapeRight:
			[self.webView stringByEvaluatingJavaScriptFromString:@"window.__defineGetter__('orientation',function(){return -90;});window.onorientationchange();"];
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			[self.webView stringByEvaluatingJavaScriptFromString:@"window.__defineGetter__('orientation',function(){return 180;});window.onorientationchange();"];
			break;
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self updateOrientation];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO
									   animated:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if( _delegate )
	{
		// we can remove the URL since on reload it will be reset
		[_URL release];
		_URL = nil;
		_requested = NO;
	}

    // Release any retained subviews of the main view.
	self.toolbarItems = nil;
	self.toolbar = nil;
}

- (void)dealloc
{
	self.toolbarItems = nil;
	[_toolbar release];
	[_URL release];
    [super dealloc];
}

- (UIWebView *) webView
{
	return (UIWebView *) self.view;
}

- (void) setURL:(NSURL *)URL
{
	if( _URL != URL )
	{
		if( _requested )
		{
			if( _URL )
			{
				[self.webView stopLoading];
				[_URL release];
			}
			
			_URL = [URL retain];
			_requested = ( _URL != nil );
			if( _URL )
			{
				NSURLRequest *request = [NSURLRequest requestWithURL:_URL];
				[self.webView loadRequest:request];
			}
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:_URL != nil];
		}
		else
		{
			[_URL release];
			_URL = [URL retain];
		}
	}
}

#pragma mark UIWebViewDelegate functions

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	UIButton *stopButton = [self.toolbarItems objectAtIndex:3];
	stopButton.enabled = YES;
	
	UIButton *refreshButton = [self.toolbarItems objectAtIndex:4];
	refreshButton.enabled = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIButton *backButton = [self.toolbarItems objectAtIndex:0];
	backButton.enabled = self.webView.canGoBack;

	UIButton *forwardButton = [self.toolbarItems objectAtIndex:1];
	forwardButton.enabled = self.webView.canGoForward;

	UIButton *stopButton = [self.toolbarItems objectAtIndex:3];
	stopButton.enabled = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIButton *backButton = [self.toolbarItems objectAtIndex:0];
	backButton.enabled = self.webView.canGoBack;
	
	UIButton *forwardButton = [self.toolbarItems objectAtIndex:1];
	forwardButton.enabled = self.webView.canGoForward;
	
	UIButton *stopButton = [self.toolbarItems objectAtIndex:3];
	stopButton.enabled = NO;
}

@end
