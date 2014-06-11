//
//  DMUnitCell.h
//  DM Tools
//
//  Created by hamouras on 3/21/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMUnit;

#define kMaxCellAttributes	4
#define kMaxCellStates		8

@interface DMUnitCell : UITableViewCell
{
	UIView *		_backView;
	UILabel *		_name;
	UIImageView *	_icon;
	UILabel *		_hp;
	UILabel *		_initiative;
	UIButton *		_statusButton;
	UIButton *		_accessoryButton;
	NSArray *		_attribLabels;
	NSArray *		_attribValues;
	NSArray *		_stateIcons;
}

@property (nonatomic, retain) IBOutlet UIView *			backView;
@property (nonatomic, retain) IBOutlet UILabel *		name;
@property (nonatomic, retain) IBOutlet UIImageView *	icon;
@property (nonatomic, retain) IBOutlet UILabel *		hp;
@property (nonatomic, retain) IBOutlet UILabel *		initiative;
@property (nonatomic, retain) IBOutlet UIButton *		statusButton;
@property (nonatomic, retain) IBOutlet UIButton *		accessoryButton;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *		attribLabels;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *		attribValues;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *	stateIcons;

- (void) setupWithUnit:(DMUnit *)unit forActiveTable:(BOOL)activeTable;

@end
