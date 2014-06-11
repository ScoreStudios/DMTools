//
//  DMUnitInfoCell.m
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/1/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import "DMUnitInfoCell.h"
#import "DMUnit.h"
#import "DMLibrary.h"
#import "DMAvatarViewController.h"
#import "DMDataManager.h"

#define kFieldName			0
#define kFieldRace			1
#define kFieldClass			2

@implementation DMUnitInfoCell

@synthesize unit = _unit;
@synthesize library = _library;
@synthesize icon = _icon;
@synthesize nameField = _nameField;
@synthesize raceField = _raceField;
@synthesize charClassField = _charClassField;
@synthesize viewController = _viewController;
@synthesize delegate = _delegate;

- (id) initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]) != nil)
	{
        // Initialization code
	}
    return self;
}

- (void) dealloc
{
	[_unit release];
	[_library release];
	[_icon release];
	[_nameField release];
	[_raceField release];
	[_charClassField release];
	
	[super dealloc];
}

- (void) setUnit:(DMUnit *)unit asReadOnly:(BOOL)readonly
{
	if (unit != _unit)
	{
		[_unit release];
		_unit = [unit retain];
		[_icon setImage:unit.avatar
			   forState:UIControlStateNormal];
		_nameField.text = unit.name;
		_raceField.text = unit.race;
		_charClassField.text = unit.charClass;
		
		_nameField.enabled = !readonly;
		_nameField.textColor = readonly ? [UIColor darkGrayColor] : [UIColor colorWithRed:0.0f
																					green:0.25f
																					 blue:0.5f
																					alpha:1.0f];
	}
}

- (void) setInfoObject:(id)object
{
	if( [object isKindOfClass:[DMLibrary class]] )
	{
		DMLibrary* library = object;
		if( library != _library )
		{
			[_library release];
			_library = [library retain];
		}
		[self setUnit:library.baseTemplate
		   asReadOnly:library.isReadonlyTemplate];
	}
	else if( [object isKindOfClass:[DMUnit class]] )
	{
		DMUnit* unit = object;
		[self setUnit:unit
		   asReadOnly:NO];
	}
}


-(BOOL) canBecomeFirstResponder
{
	return YES;
}

- (void) reloadAvatar
{
	[_icon setImage:_unit.avatar
		   forState:UIControlStateNormal];
}

#pragma mark event functions

- (IBAction) showAvatarSelectView:(id)sender;
{
	[self becomeFirstResponder];
	DMAvatarViewController* avatarViewController = [[DMAvatarViewController alloc] initWithSelectedAvatar:_unit.avatarName];
	avatarViewController.delegate = _delegate;
	[_viewController.navigationController pushViewController:avatarViewController
													animated:YES];
	[avatarViewController release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL valid = YES;
	if( _library
	   && textField.tag == kFieldName )
	{
		NSString* name = [textField.text stringByReplacingCharactersInRange:range
																 withString:string];
		valid = [DMDataManager canRenameLibrary:_library
									withNewName:name];
	}
	textField.textColor = valid ? [UIColor colorWithRed:0.0f
												  green:0.25f
												   blue:0.5f
												  alpha:1.0f] : [UIColor redColor];

	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	const NSInteger tag = textField.tag;	

	// process Info group
	switch (tag)
	{
		case kFieldName:	// name
			if( _library )
			{
				NSString* name = textField.text;
				if ( ![DMDataManager canRenameLibrary:_library
										  withNewName:name] )
				{
					UIAlertView* alert = [[UIAlertView alloc] initWithTitle:name
																	message:@"A template with this name already exists"
																   delegate:nil
														  cancelButtonTitle:@"Dismiss"
														  otherButtonTitles:nil];
					[alert show];
					[alert release];
					break;
				}
				else
					[DMDataManager renameLibrary:_library
									 withNewName:name];
			}
			else
				_unit.name = textField.text;
			break;
			
		case kFieldRace:	// race
			_unit.race = textField.text;
			break;
			
		case kFieldClass:	// class
			_unit.charClass = textField.text;
			break;
			
		default:
			NSAssert(0, @"invalid item for text field event in Info group");
			break;
	}
	[_delegate unitInfoCellHasModifiedUnit:self];
}


@end
