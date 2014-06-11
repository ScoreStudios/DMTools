//
//  DMUnitViewController.h
//  DM Tools
//
//  Created by hamouras on 3/20/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMTitleEditProtocol.h"
#import "DMNumberEditView.h"
#import "DMPickerEditView.h"
#import "DMTextEditView.h"
#import "DMUnitInfoCell.h"
#import "DMTableViewCell.h"
#import "SENavigationController.h"
#import "SEPushPopViewControllerProtocol.h"

@class DMUnit;
@class DMLibrary;
@class DMSection;
@protocol DMUnitViewControllerDelegate;
@protocol DMTextEditViewDelegate;

@interface DMUnitViewController : UITableViewController
<SEPushPopViewControllerProtocol,
DMTableViewCellDelegate,
DMUnitInfoCellDelegate,
DMPickerEditViewDelegate,
DMNumberEditViewDelegate,
DMTextEditViewDelegate,
DMAvatarViewControllerDelegate,
UITextViewDelegate>
{
	SEL					_editActionOriginal;
	BOOL				_tableEditing;
	
	NSMutableArray *	_sections;
	
	UIImage *			_openEye;
	UIImage *			_closedEye;
	NSArray *			_groupTypes;
	UIColor *			_headerColor;
}

@property (nonatomic, readonly) DMUnit * unit;
@property (nonatomic, readonly) DMLibrary * library;
@property (nonatomic, assign) id<DMUnitViewControllerDelegate> delegate;

+ (void) setDefaultDisplayForUnit:(DMUnit*)unit;

- (id)initWithUnit:(DMUnit *)unit;
- (id)initWithLibrary:(DMLibrary*)library;

@end

@protocol DMUnitViewControllerDelegate <NSObject>

@required;
- (void) unitViewController:(DMUnitViewController *)unitViewController finishedEditingUnit:(DMUnit *) unit;

@optional;
- (void) unitViewController:(DMUnitViewController *)unitViewController refreshUnit:(DMUnit *) unit;

@end
