//
//  LibraryViewController.h
//  testsplitview
//
//  Created by hamouras on 30/07/2010.
//  Copyright Score Studios 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMUnitViewController.h"
#import "SECollatedViewController.h"
#import "SEPushPopViewControllerProtocol.h"

#define kPlayersSection		0
#define kMonstersSection	1
#define kSectionsCount		2

@class InitiativeViewController;
@class DMUnit;
@class DMLibrary;

typedef enum DMSelectedGroup
{
	DMSelectedGroupPlayers		= 0,
	DMSelectedGroupMonsters		= 1
} DMSelectedGroup;

typedef union DMOldSelection
{
	struct
	{
		DMSelectedGroup	group		: 2;
		NSUInteger		encounter	: 10;
		NSUInteger		player		: 10;
		NSUInteger		monster		: 10;
	};
	NSUInteger	value;
} DMOldSelection;

typedef union DMSelection
{
	struct
	{
		DMSelectedGroup	group	: 1;
		NSUInteger		player	: 15;
		NSUInteger		monster	: 16;
	};
	NSUInteger	value;
} DMSelection;

@interface LibraryViewController : SECollatedViewController<
SEPushPopViewControllerProtocol,
UIActionSheetDelegate,
DMUnitViewControllerDelegate,
DMNumberEditViewDelegate>
{
    InitiativeViewController *	_initiativeViewController;
	UISegmentedControl*			_groupSelector;
	DMSelection					_selection;
	DMUnit *					_currentUnit;
	DMLibrary *					_library;
}

@property (nonatomic, retain) IBOutlet InitiativeViewController *initiativeViewController;
@property (nonatomic, retain) DMLibrary * library;

- (IBAction)groupSelected:(id)sender;

@end
