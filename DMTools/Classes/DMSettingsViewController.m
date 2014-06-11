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
@property (nonatomic, readonly) DBRestClient* restClient;

@end

@implementation DMSettingsViewController
@synthesize iTunesURL = _iTunesURL;
@dynamic restClient;

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
	[_restClient release];
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
	
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
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
				
			case StatusDBImporting:
				[self updateDropboxButtons];
				[self.restClient loadMetadata:@"/"
									 withHash:_syncHash];
				// return here so that the status is not reset
				// it will be reset when import has finished
				return;
				
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
	[self presentModalViewController:mailViewController
							animated:YES];
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

- (void) linkToDropbox:(NSIndexPath*)indexPath
{
	if( [[DBSession sharedSession] isLinked] )
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		_pendingCount = 0;
		if( _status == StatusDBImporting
		   || _status == StatusDBExporting )
			_status = StatusIdle;
		
		[[DBSession sharedSession] unlinkAll];
		[self updateDropboxButtons];
		[_restClient release];
		_restClient = nil;
	}
	else
		[[DBSession sharedSession] link];
}

- (void) importFromDropbox:(NSIndexPath*)indexPath
{
	if( _status != StatusIdle )
		return;
	_status = StatusDBImporting;

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dropbox Import"
													message:@"Are you sure you want to import from Dropbox? Some data might be overwritten."
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"Import", nil];
	[alert show];
	[alert release];
}

- (void) exportToDropbox:(NSIndexPath*)indexPath
{
	if( _status != StatusIdle )
		return;
	_status = StatusDBExporting;
	[self updateDropboxButtons];
	
    [self.restClient loadMetadata:@"/"
						 withHash:_syncHash];
}

#pragma mark Dropbox delegate/support methods

- (void) updateDropboxButtons
{
	const NSUInteger dbGroup = [(DMSettings*)_settings dropboxGroupIndex];
	SESetting* dbLink = [_settings settingAtIndex:0
										  inGroup:dbGroup];
	dbLink.label = [[DBSession sharedSession] isLinked] ? kUnlinkDropbox : kLinkDropbox;

	SESetting* dbImport = [_settings settingAtIndex:1
											inGroup:dbGroup];
	dbImport.label = _status == StatusDBImporting ? @"Importing ..." : kImportFromDropbox;
	SESetting* dbExport = [_settings settingAtIndex:2
											inGroup:dbGroup];
	dbExport.label = _status == StatusDBExporting ? @"Exporting ..." : kExportToDropbox;
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:dbGroup]
				  withRowAnimation:UITableViewRowAnimationNone];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = ( _status == StatusDBImporting || _status == StatusDBExporting );
}

- (DBRestClient*)restClient
{
	if( _restClient == nil )
	{
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void) importDropboxFiles
{
	NSAssert( _status == StatusDBImporting, @"invalid import/export state" );
	++_pendingCount;
	
	if( ( _xmlPaths.allKeys.count || _iconPaths.count )
	   && [[DBSession sharedSession] isLinked] )
	{
		NSString* tempPath = [DMDataManager temporaryPath];
		for( NSString* iconPath in _iconPaths )
		{
			++_pendingCount;
			NSString* iconName = [iconPath lastPathComponent];
			NSString* tempFile = [tempPath stringByAppendingPathComponent:iconName];
			[self.restClient loadThumbnail:iconPath
									ofSize:@"iphone_bestfit"
								  intoPath:tempFile];
		}
		
		for( NSString* xmlPath in _xmlPaths.allKeys )
		{
			++_pendingCount;
			NSString* xmlName = [xmlPath lastPathComponent];
			NSString* tempFile = [tempPath stringByAppendingPathComponent:xmlName];
			[self.restClient loadFile:xmlPath
							 intoPath:tempFile];
		}
	}
	
	--_pendingCount;
	_status = _pendingCount ? StatusDBImporting : StatusIdle;
	[self updateDropboxButtons];
}

- (void) exportDropboxFiles
{
	NSAssert( _status == StatusDBExporting, @"invalid import/export state" );
	++_pendingCount;
	
	if( [[DBSession sharedSession] isLinked] )
	{
		NSString* tempPath = [DMDataManager temporaryPath];
		NSFileManager* fileManager = [NSFileManager defaultManager];
		
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
			
			NSString* tempFile = [tempPath stringByAppendingPathComponent:savename];
			if( [fileManager createFileAtPath:tempFile
									 contents:data
								   attributes:nil] )
			{
				++_pendingCount;
				NSString* key = [NSString stringWithFormat:@"/%@", savename];
				NSString* revision = [_xmlPaths objectForKey:key];
				[self.restClient uploadFile:savename
									 toPath:@"/"
							  withParentRev:revision
								   fromPath:tempFile];
			}
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
			
			NSString* tempFile = [tempPath stringByAppendingPathComponent:savename];
			if( [fileManager createFileAtPath:tempFile
									 contents:data
								   attributes:nil] )
			{
				++_pendingCount;
				NSString* key = [NSString stringWithFormat:@"/%@", savename];
				NSString* revision = [_xmlPaths objectForKey:key];
				[self.restClient uploadFile:savename
									 toPath:@"/"
							  withParentRev:revision
								   fromPath:tempFile];
			}
		}
	}
	
	--_pendingCount;
	_status = _pendingCount ? StatusDBExporting : StatusIdle;
	[self updateDropboxButtons];
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata
{
	[_syncHash release];
	_syncHash = [metadata.hash retain];
    
	NSArray* iconExtensions = [NSArray arrayWithObjects:@"jpg", @"png", nil];
	NSMutableDictionary* xmlPaths = [NSMutableDictionary new];
	NSMutableArray* iconPaths = [NSMutableArray new];
	for( DBMetadata* child in metadata.contents )
	{
        NSString* extension = [[child.path pathExtension] lowercaseString];
		if( !child.isDirectory )
		{
			if( [extension isEqualToString:@"xml"] )
			{
				NSString* revision = child.rev;
				[xmlPaths setObject:revision
							 forKey:child.path];
			}
			else if( [iconExtensions indexOfObject:extension] != NSNotFound )
				[iconPaths addObject:child.path];
		}
    }
	[_iconPaths release];
	_iconPaths = iconPaths;
	[_xmlPaths release];
	_xmlPaths = xmlPaths;

	if( _status == StatusDBImporting )
		[self importDropboxFiles];
	else if( _status == StatusDBExporting )
		[self exportDropboxFiles];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
	if( _status == StatusDBImporting )
		[self importDropboxFiles];
	else if( _status == StatusDBExporting )
		[self exportDropboxFiles];
}


- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
	NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
	_status = StatusIdle;
	_pendingCount = 0;
	[self updateDropboxButtons];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath metadata:(DBMetadata*)metadata
{
	if( _pendingCount )
	{
		NSAssert( _status == StatusDBImporting, @"invalid import/export state" );

		dispatch_async( dispatch_get_main_queue(), ^{
			[DMDataManager importImage:destPath];
		});
		
		--_pendingCount;
		if( !_pendingCount )
		{
			_status = StatusIdle;
			[self updateDropboxButtons];
		}
	}
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error
{
	NSLog(@"restClient:loadThumbnailFailedWithError: %@", [error localizedDescription]);
	if( _pendingCount )
	{
		NSAssert( _status == StatusDBImporting, @"invalid import/export state" );
		--_pendingCount;
		if( !_pendingCount )
		{
			_status = StatusIdle;
			[self updateDropboxButtons];
		}
	}
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
	if( _pendingCount )
	{
		NSAssert( _status == StatusDBImporting, @"invalid import/export state" );

		dispatch_async( dispatch_get_main_queue(), ^{
			DMParserResult result = [DMDataManager importXml:destPath];
			if( result == DMParserOldFormat )
			{
				NSString* filename = [destPath lastPathComponent];
				NSString* msg = [NSString stringWithFormat:@"Imported file %@ is in an old format. Please remove it from your Dropbox folder, to avoid conflicts with future imports.", filename];
				UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Import"
																	message:msg
																   delegate:nil
														  cancelButtonTitle:@"Dismiss"
														  otherButtonTitles:nil];
				[alertView show];
				[alertView release];
			}
		});
		
		--_pendingCount;
		if( !_pendingCount )
		{
			_status = StatusIdle;
			[self updateDropboxButtons];
		}
	}
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
	NSLog(@"restClient:loadFileFailedWithError: %@", [error localizedDescription]);
	if( _pendingCount )
	{
		NSAssert( _status == StatusDBImporting, @"invalid import/export state" );
		--_pendingCount;
		if( !_pendingCount )
		{
			_status = StatusIdle;
			[self updateDropboxButtons];
		}
	}
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
	[[NSFileManager defaultManager] removeItemAtPath:srcPath
											   error:nil];
	if( _pendingCount )
	{
		NSAssert( _status == StatusDBExporting, @"invalid import/export state" );
		--_pendingCount;
		if( !_pendingCount )
		{
			_status = StatusIdle;
			[self updateDropboxButtons];
		}
	}
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
	NSLog(@"restClient:uploadFileFailedWithError: %@", [error localizedDescription]);
	NSString* srcPath = [[error userInfo] objectForKey:@"sourcePath"];
	if( srcPath )
	{
		[[NSFileManager defaultManager] removeItemAtPath:srcPath
												   error:nil];
	}
	if( _pendingCount )
	{
		NSAssert( _status == StatusDBExporting, @"invalid import/export state" );
		--_pendingCount;
		if( !_pendingCount )
		{
			_status = StatusIdle;
			[self updateDropboxButtons];
		}
	}
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
	[self presentModalViewController:mailViewController
							animated:YES];
	[mailViewController release];
}

@end
