//
//  DMSettingsViewController.m
//  DM Tools
//
//  Created by hamouras on 4/3/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "DMSettingsViewController.h"
#import "DMToolsAppDelegate.h"
#import "DMSettings.h"
#import "DMDataManager.h"
#import "DMUnit.h"
#import "DMLibrary.h"
#import "DMEncounter.h"
#import "NSMutableString+DMToolsExport.h"
#import "SEWebViewController.h"
#import "InitiativeViewController.h"

@interface DMSettingsViewController()

@property (nonatomic, retain) NSURL* iTunesURL;

@end

@implementation DMSettingsViewController
@synthesize iTunesURL = _iTunesURL;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ( (self = [super initWithCoder:aDecoder
							 settings:[DMSettings settings]] ) )
	{
	}
	return self;
}

- (void)dealloc
{
	[_iconPaths release];
	[_xmlPaths release];
	[_syncHash release];
	[_iTunesURL release];
    [super dealloc];
}

/*
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.preferredContentSize = CGSizeMake(320.0, 480.0);
}

/*
- (void) viewDidUnload
{
	[super viewDidUnload];
}
*/

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - unit management

#pragma mark UIAlertViewDelegate functions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex != 0 )
	{
		switch(	_status )
		{
			case StatusImporting:
				[DMDataManager importData];
				break;
				
			default:
				break;
		};
	}
	
	_status = StatusIdle;
}

#pragma mark events

- (void) exportToMail:(NSIndexPath*)indexPath
{
	if( _status != StatusIdle )
		return;
	
	if ([MFMailComposeViewController canSendMail] == NO)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Export to Mail"
														message:@"The current device is not configured for sending mail"
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return;
	}
	
	_status = StatusExporting;
	
	NSString* text = @"DM Export data\n\n";
	
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	mailViewController.mailComposeDelegate = (DMToolsAppDelegate*)[[UIApplication sharedApplication] delegate];
	[mailViewController setSubject:@"DM Tools Export"];
	[mailViewController setMessageBody:text
								isHTML:NO];
	
	NSDictionary* libraries = [DMDataManager libraries];
	NSArray* libraryNames = [DMDataManager sortedLibraryNames];
	for( NSString* libraryName in libraryNames )
	{
		DMLibrary* library = [libraries objectForKey:libraryName];
		NSString* savename = [library.name stringByReplacingOccurrencesOfString:@" "
																	 withString:@"_"];
		savename = [savename stringByAppendingPathExtension:@"dml"];
		savename = [savename stringByAppendingPathExtension:@"xml"];

		NSMutableString *xmlText = [NSMutableString new];
		[xmlText appendDMToolsHeader];
		[xmlText appendLibrary:library
					   atLevel:0];
		[xmlText appendDMToolsFooter];
		
		NSData *data = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
		[xmlText release];

		[mailViewController addAttachmentData:data
									 mimeType:@"text/xml"
									 fileName:savename];
	}

	{
		DMEncounter *encounter = [DMDataManager currentEncounter];
		NSString* savename = [encounter.name stringByReplacingOccurrencesOfString:@" "
																	   withString:@"_"];
		savename = [savename stringByAppendingPathExtension:@"dme"];
		savename = [savename stringByAppendingPathExtension:@"xml"];
		
		NSMutableString *xmlText = [NSMutableString new];
		[xmlText appendDMToolsHeader];
		[xmlText appendEncounter:encounter
						 atLevel:0];
		[xmlText appendDMToolsFooter];
		
		NSData *data = [xmlText dataUsingEncoding:NSUTF8StringEncoding];
		[xmlText release];
		
		[mailViewController addAttachmentData:data
									 mimeType:@"text/xml"
									 fileName:savename];
	}
	
	if ([[UIDevice currentDevice] isIPad])
		mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:mailViewController
					   animated:YES
					 completion:nil];
	[mailViewController release];

	_status = StatusIdle;
}

- (void) importFromITunes:(NSIndexPath*)indexPath
{
	if( _status != StatusIdle )
		return;
	_status = StatusImporting;
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iTunes Import"
													message:@"Are you sure you want to import from iTunes? Some data might be overwritten."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Import", nil];
	[alert show];
	[alert release];
}

- (void) exportToITunes:(NSIndexPath*)indexPath
{
	if( _status != StatusIdle )
		return;
	_status = StatusExporting;
	
	[DMDataManager exportData];

	_status = StatusIdle;
}

#define kDMToolsAppID	@"377688628"

- (NSURLRequest *) connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
	if (response)
		self.iTunesURL = [response URL];
	return request;
}

// No more redirects; use the last URL saved
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] openURL:_iTunesURL];
}


- (void) rateDMTools:(NSIndexPath*)indexPath
{
	NSString *link = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@?mt=8", kDMToolsAppID];
	NSURL *url = [NSURL URLWithString:link];
	self.iTunesURL = url;
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url]
															delegate:self
													startImmediately:YES];
	[conn release];
}

- (void) linkToScore:(NSIndexPath*)indexPath
{
	NSURL *url = [NSURL URLWithString:@"http://score-studios.jp/i/?page=games"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) linkToForums:(NSIndexPath*)indexPath
{
	NSURL *url = [NSURL URLWithString:@"http://score-studios.jp/forums/"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) mailToScore:(NSIndexPath*)indexPath
{
	if ([MFMailComposeViewController canSendMail] == NO)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail"
														message:@"The current device is not configured for sending mail"
													   delegate:nil
											  cancelButtonTitle:@"Dismiss"
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		return;
	}
	
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	mailViewController.mailComposeDelegate = (DMToolsAppDelegate*)[[UIApplication sharedApplication] delegate];
	[mailViewController setToRecipients:[NSArray arrayWithObject:@"info@score-studios.jp"]];
	[mailViewController setSubject:@"DM Tools Feedback"];
//	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
	UIDevice* currentDevice = [UIDevice currentDevice];
	NSString* msg = [NSString stringWithFormat:@"Dear Dungeon Master,\n\n\nDMTools v%@, %@ iOS v%@",
					 version,
					 [currentDevice isIPad] ? @"iPad" : @"iPhone",
					 [currentDevice systemVersion]];
	[mailViewController setMessageBody:msg
								isHTML:NO];
	if ([[UIDevice currentDevice] isIPad])
		mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:mailViewController
					   animated:YES
					 completion:nil];
	[mailViewController release];
}

@end
