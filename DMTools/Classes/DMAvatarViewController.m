//
//  DMAvatarViewController.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/18/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMAvatarViewController.h"
#import "DMAvatarCell.h"
#import "DMDataManager.h"

#define kIconCellHeight		80.0f
#define kThumbnailSize		64.0f

@implementation DMAvatarViewController
@synthesize delegate = _delegate;

- (id)initWithSelectedAvatar:(NSString*)avatarName
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
		
		_selectedAvatarName = [avatarName copy];
		_selectedAvatarIndex = NSNotFound;
    }
    return self;
}

- (void) dealloc
{
	_enumerate = NO;
	[_imageNames release];
	[_avatars release];
	[_selectedAvatar release];
	[_selectedAvatarName release];
	[_selectedIcon release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) enumerateAvatars
{
	NSString* paths[2] = {
		[DMDataManager avatarsPath],
		[DMDataManager userAvatarsPath]
	};
	NSFileManager* fileManager = [NSFileManager defaultManager];

	dispatch_queue_t queue = dispatch_get_main_queue();
	__block NSUInteger avatarCounter = 0;
	const CGRect avatarRect = CGRectMake( 0.0f, 0.0f, kThumbnailSize, kThumbnailSize );
	
	for( NSUInteger p = 0 ; p < 2 ; ++p )
	{
		NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:paths[p]];
		NSString* filePath;
		while( ( filePath = [enumerator nextObject] ) != nil )
		{
			NSString* extension = [filePath pathExtension];
			if( [extension isEqualToString:@"png"]
			   || [extension isEqualToString:@"jpg"] )
			{
				NSString* imageName = [filePath lastPathComponent];
				UIImage* avatar = [DMDataManager avatarNamed:imageName];

				UIGraphicsBeginImageContextWithOptions( avatarRect.size, NO, 0.0f );
				// now redraw our image in a smaller rectangle.
				[avatar drawInRect:avatarRect];
				// make a "copy" of the image from the current context
				avatar = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				
				[_imageNames addObject:imageName];
				[_avatars addObject:avatar];
				
				if( _selectedAvatarName
				   && [imageName caseInsensitiveCompare:_selectedAvatarName] == NSOrderedSame )
				{
					_selectedAvatarIndex = avatarCounter;
					[_selectedAvatarName release];
					[_selectedAvatar release];
					_selectedAvatarName = nil;
					_selectedAvatar = nil;
				}
				
				++avatarCounter;
				if( ( avatarCounter % 4 ) == 0 )
				{
					dispatch_async( queue, ^{
						[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_rowCount++
																										   inSection:0]]
											  withRowAnimation:UITableViewRowAnimationFade];
					});
				}
			}

			if( !_enumerate )
				break;
		}

		if( !_enumerate )
			break;
	}

	_enumerate = NO;
	dispatch_async( queue, ^{
		// process remainders
		if( ( avatarCounter % 4 ) != 0 )
		{
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_rowCount++
																							   inSection:0]]
								  withRowAnimation:UITableViewRowAnimationFade];
		}
	});
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);

	_selectedIcon = [[UIImage imageNamed:@"checkbox_2.png"] retain];
	_imageNames = [NSMutableArray new];
	_avatars = [NSMutableArray new];

	_enumerate = YES;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Clear"
																			   style:UIBarButtonItemStyleBordered
																			  target:self
																			  action:@selector(clearSelection:)] autorelease];
	dispatch_queue_t queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
	dispatch_async( queue, ^{
		[self enumerateAvatars];
	});
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.navigationItem.rightBarButtonItem = nil;
	_enumerate = NO;
	[_selectedIcon release];
	[_imageNames release];
	[_avatars release];
	_selectedIcon = nil;
	_imageNames = nil;
	_avatars = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES
									   animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
	if( _selectedAvatarIndex != NSNotFound )
	{
		[_delegate avatarViewController:self
						 selectedAvatar:[_avatars objectAtIndex:_selectedAvatarIndex]
								  named:[_imageNames objectAtIndex:_selectedAvatarIndex]];
	}
	else
	{
		[_delegate avatarViewController:self
						 selectedAvatar:nil
								  named:nil];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) selectAvatar:(id)sender
{
	UIButton* button = sender;
	const NSUInteger oldAvatarIndex = _selectedAvatarIndex;
	const NSUInteger newAvatarIndex = button.tag;
	if( oldAvatarIndex != newAvatarIndex )
	{
		const NSUInteger oldIndexRow = ( oldAvatarIndex != NSNotFound ) ? ( oldAvatarIndex / 4 ) : NSNotFound;
		const NSUInteger newIndexRow = ( newAvatarIndex / 4 );
		_selectedAvatarIndex = newAvatarIndex;
		[_selectedAvatar release];
		_selectedAvatar = nil;
		
		NSIndexPath* oldIndexPath = nil;
		if( oldIndexRow != NSNotFound
		   && oldIndexRow != newIndexRow )
		{
			oldIndexPath = [NSIndexPath indexPathForRow:oldIndexRow
											  inSection:0];
		}
		
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:
												[NSIndexPath indexPathForRow:newIndexRow
																   inSection:0],
												oldIndexPath,
												nil]
							  withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void) clearSelection:(id)sender
{
	if( _selectedAvatarIndex != NSNotFound )
	{
		const NSUInteger oldIndexRow = _selectedAvatarIndex / 4;
		_selectedAvatarIndex = NSNotFound;
		[_selectedAvatar release];
		_selectedAvatar = nil;
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:oldIndexRow
																						   inSection:0]]
							  withRowAnimation:UITableViewRowAnimationNone];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"DMAvatarCell";
	
	DMAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		NSArray* nibObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
															owner:nil
														  options:nil];
		cell = [nibObjects objectAtIndex:0];
		for( NSUInteger i = 0 ; i < 4 ; ++i )
		{
			UIButton* button = [cell.avatars objectAtIndex:i];
			[button addTarget:self
					   action:@selector(selectAvatar:)
			 forControlEvents:UIControlEventTouchUpInside];
		}
	}
	
	const NSUInteger rowIndex = indexPath.row;
	const NSUInteger maxAvatars = _avatars.count;
	// Configure the cell...
	for( NSUInteger i = 0 ; i < 4 ; ++i )
	{
		const NSUInteger avatarIndex = rowIndex * 4 + i;
		UIImage* image = ( avatarIndex < maxAvatars ) ? [_avatars objectAtIndex:avatarIndex] : nil;
		UIButton* button = [cell.avatars objectAtIndex:i];
		
		if( image )
		{
			if( avatarIndex == _selectedAvatarIndex )
			{
				if( _selectedAvatar )
					image = _selectedAvatar;
				else
				{
					const CGRect avatarRect = CGRectMake( 0.0f, 0.0f, kThumbnailSize, kThumbnailSize );
					const CGSize iconSize = _selectedIcon.size;
					const CGRect iconRect = CGRectMake( 0.0f, kThumbnailSize - iconSize.height, iconSize.width, iconSize.height );
					UIGraphicsBeginImageContextWithOptions( CGSizeMake( kThumbnailSize, kThumbnailSize ), NO, 0.0f );
					// now redraw our image in a smaller rectangle.
					[image drawInRect:avatarRect];
					[_selectedIcon drawInRect:iconRect];
					// make a "copy" of the image from the current context
					image = UIGraphicsGetImageFromCurrentImageContext();
					UIGraphicsEndImageContext();
					_selectedAvatar = [image retain];
				}
			}
			
			button.tag = avatarIndex;
			[button setImage:image
					forState:UIControlStateNormal];
			button.hidden = NO;
		}
		else
		{
			button.tag = -1;
			[button setImage:nil
					forState:UIControlStateNormal];
			button.hidden = YES;
		}
	}
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kIconCellHeight;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

@end
