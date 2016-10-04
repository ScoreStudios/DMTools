//
//  SESettingsViewController.m
//  DM Tools
//
//  Created by hamouras on 4/2/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import "SESettingsViewController.h"
#import "SESettings.h"

#define kControlPaddingX		7.0f
#define kControlPaddingY		6.0f
#define kButtonWidth			180.0f
#define kHeaderHeight			24.0f
#define kRowHeight				40.0f

@implementation SESettingsViewCell
@synthesize control = _control;

- (void) dealloc
{
	[super dealloc];
	[_control release];
}
@end

	@implementation SESettingsViewController

- (id) initWithCoder:(NSCoder *)decoder settings:(SESettings *)settings
{
    self = [super initWithCoder:decoder];
    if (self)
	{
		_settings = [settings retain];
    }
    return self;
}

- (void)dealloc
{
	[_settings release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
/*
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return YES;
}
*/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self.tableView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
}

#pragma mark actions/events

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	const NSInteger tag = textField.tag;
	const NSInteger section = (tag >> 16) & 0xFFFF;
	const NSInteger row = tag & 0xFFFF;
	
	SESetting *setting = [_settings settingAtIndex:row
										   inGroup:section];
	switch (setting.type)
	{
		case SettingTypeNumber:
			setting.integerValue = [textField.text integerValue];
			break;

		case SettingTypeString:
			setting.stringValue = textField.text;
			break;

		default:
			break;
	}
	
	if (setting.selector)
	{
		id target = setting.target ? setting.target : self;
		[target performSelector:setting.selector
					 withObject:[NSIndexPath indexPathForRow:row
												   inSection:section]];
	}
}

- (void) controlChangedEvent:(id)sender
{
	const NSInteger tag = [sender tag];
	const NSInteger section = (tag >> 16) & 0xFFFF;
	const NSInteger row = tag & 0xFFFF;
	
	SESetting *setting = [_settings settingAtIndex:row
										   inGroup:section];
	switch (setting.type)
	{
		case SettingTypeBoolean:
		{
			UISwitch *onoff = sender;
			setting.booleanValue = onoff.on;
			break;
		}
		case SettingTypeSelection:
		{
			UISegmentedControl *segmentedControl = sender;
			setting.integerValue = segmentedControl.selectedSegmentIndex;
			break;
		}
		default:
			break;
	}
	
	if (setting.selector)
	{
		id target = setting.target ? setting.target : self;
		[target performSelector:setting.selector
					 withObject:[NSIndexPath indexPathForRow:row
												   inSection:section]];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _settings.groups.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [_settings.groupNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *groupItems = [_settings.groups objectAtIndex:section];
    return groupItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    
    SESettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[SESettingsViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:CellIdentifier] autorelease];
    }
    
	CGRect frame = cell.frame;
	frame.size.height = tableView.rowHeight;
	cell.frame = frame;
	
	if( cell.control )
	{
		[cell.control removeFromSuperview];
		cell.control = nil;
	}
	
	cell.contentView.contentMode = UIViewContentModeRight;
	CGRect contentRect = cell.contentView.bounds;
	UIControl *control = nil;
	
	const NSInteger section = indexPath.section;
	const NSInteger row = indexPath.row;
	// Configure the cell...
	SESetting *setting = [_settings settingAtIndex:row
										   inGroup:section];
	cell.textLabel.text = setting.label;
	cell.detailTextLabel.text = @"";
	cell.backgroundColor = setting.color ? setting.color : [UIColor whiteColor];
	switch (setting.type)
	{
		case SettingTypeBoolean:
		{
			UISwitch *onoff = [UISwitch new];
			CGRect rect = onoff.frame;
			rect.origin.x = contentRect.size.width - (rect.size.width + kControlPaddingX);
			rect.origin.y = floorf((kRowHeight - rect.size.height) * 0.5f);
			onoff.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			onoff.frame = rect;
			onoff.on = setting.booleanValue;
			// set event handler
			[onoff addTarget:self
					  action:@selector(controlChangedEvent:)
			forControlEvents:UIControlEventValueChanged];
			
			control = [onoff autorelease];
			break;
		}	
		case SettingTypeNumber:
			NSLog(@"todo");
			break;
			
		case SettingTypeAction:
			cell.detailTextLabel.text = setting.detailLabel;
			break;
			
		case SettingTypeString:
		{
			const BOOL isNumber = (setting.type == SettingTypeNumber);
			const CGFloat width = isNumber ? 80.0f : floorf(contentRect.size.width * 0.6f);
			const CGRect rect = CGRectMake(contentRect.size.width - (width + kControlPaddingX),
										   kControlPaddingY,
										   width,
										   kRowHeight - kControlPaddingY * 2.0f);
			
			UITextField *textField = [[UITextField alloc] initWithFrame:rect];
			textField.text = setting.stringValue;
			textField.borderStyle = UITextBorderStyleRoundedRect;
			textField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
			textField.textAlignment = NSTextAlignmentLeft;
			// set text input params
			textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
			textField.keyboardType = isNumber ? UIKeyboardTypeNumbersAndPunctuation : UIKeyboardTypeDefault;
			textField.returnKeyType = UIReturnKeyDone;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.delegate = self;
			
			control = [textField autorelease];
			break;
		}	
		case SettingTypeSelection:
		{
			UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:setting.extras];
			CGRect rect = segmentedControl.frame;
			rect.origin.x = contentRect.size.width - (rect.size.width + kControlPaddingX);
			rect.origin.y = floorf((kRowHeight - rect.size.height) * 0.5f);
			segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
			segmentedControl.frame = rect;
			segmentedControl.selectedSegmentIndex = setting.integerValue;
			// set event handler
			[segmentedControl addTarget:self
								 action:@selector(controlChangedEvent:)
					   forControlEvents:UIControlEventValueChanged];
			
			control = [segmentedControl autorelease];
			break;
		}	
		default:
			break;
	}
    
	if (control)
	{
		// bind to content view
		control.tag = (section << 16) | row;
		[cell.contentView addSubview:control];
		cell.control = control;
	}

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSInteger section = indexPath.section;
	const NSInteger row = indexPath.row;
	SESettingsViewCell *cell = (SESettingsViewCell*) [tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil)
		return;
	
	[cell setSelected:NO
			 animated:YES];

	SESetting *setting = [_settings settingAtIndex:row
										   inGroup:section];
	switch (setting.type)
	{
		case SettingTypeBoolean:
		{
			// flip value
			setting.booleanValue ^= 1;
			// update control
			UISwitch *onoff = (UISwitch*) cell.control;
			[onoff setOn:setting.booleanValue
				animated:YES];
			break;
		}	
		case SettingTypeNumber:
			NSLog(@"todo");
			break;
			
		case SettingTypeString:
		{
			UITextField *textField = (UITextField*) cell.control;
			[textField becomeFirstResponder];
			break;
		}	
		case SettingTypeSelection:
		case SettingTypeAction:
		default:
			break;
	}
	
	if (setting.selector)
	{
		id target = setting.target ? setting.target : self;
		[target performSelector:setting.selector
					 withObject:indexPath];
	}
}
@end
