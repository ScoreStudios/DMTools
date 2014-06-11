//
//  InitiativeViewController.h
//  testsplitview
//
//  Created by hamouras on 30/07/2010.
//  Copyright Score Studios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DamageViewController.h"
#import "RollViewController.h"
#import "DMUnitViewController.h"
#import "DMTextEditView.h"

@class DMUnit;

@interface InitiativeViewController : UITableViewController
<
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIPopoverControllerDelegate,
UISplitViewControllerDelegate,
DamageViewControllerDelegate,
RollViewControllerDelegate,
DMUnitViewControllerDelegate,
DMTextEditViewDelegate
>
{
	UIPopoverController *	_naviPopoverController;
	UIPopoverController *	_toolbarPopoverController;
	NSMutableArray *		_rollArray;
	NSInteger				_curInitiative;
	NSInteger				_curInitiativeCount;
	NSInteger				_curRound;
	UIBarButtonItem *		_initiativeButton;
	SEL						_editActionOriginal;
}

@property (nonatomic, readonly) NSInteger initiativeCount;

- (BOOL) unitExists:(NSString *)name;
- (void) addUniqueUnit:(DMUnit *)unit withInitiative:(NSInteger)initiative withModifier:(NSInteger)modifier;
- (void) addUnit:(DMUnit *)unit withInitiative:(NSInteger)initiative withModifier:(NSInteger)modifier;

- (void) reloadData;
- (void) clearTable;
- (void) sortByInitiative;

@end
