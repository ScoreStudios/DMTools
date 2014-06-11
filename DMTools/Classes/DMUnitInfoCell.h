//
//  DMUnitInfoCell.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/1/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMAvatarViewController.h"

@class DMUnit;
@class DMLibrary;
@protocol DMUnitInfoCellDelegate;

@interface DMUnitInfoCell : UITableViewCell<UITextFieldDelegate>
{
	DMUnit*						_unit;
	DMLibrary*					_library;
	UIButton*					_icon;
	UITextField*				_nameField;
	UITextField*				_raceField;
	UITextField*				_charClassField;
	UITableViewController*		_viewController;
	id<DMUnitInfoCellDelegate>	_delegate;
}

@property (nonatomic, readonly) DMUnit* unit;
@property (nonatomic, readonly) DMLibrary* library;
@property (nonatomic, retain) IBOutlet UIButton* icon;
@property (nonatomic, retain) IBOutlet UITextField* nameField;
@property (nonatomic, retain) IBOutlet UITextField* raceField;
@property (nonatomic, retain) IBOutlet UITextField* charClassField;
@property (nonatomic, assign) UITableViewController* viewController;
@property (nonatomic, assign) id<DMUnitInfoCellDelegate> delegate;

- (void) setInfoObject:(id)object;
- (IBAction) showAvatarSelectView:(id)sender;
- (void) reloadAvatar;

@end

@protocol DMUnitInfoCellDelegate<DMAvatarViewControllerDelegate>

- (void) unitInfoCellHasModifiedUnit:(DMUnitInfoCell *)unitInfoCell;

@end