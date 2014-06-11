//
//  DamageViewController.h
//  DM Tools
//
//  Created by Paul Caristino on 6/11/10.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DamageViewControllerDelegate;

@interface DamageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITextField *		_HP;
	NSArray *			_attribLabels;
	NSArray *			_attribValues;
	NSMutableArray *	_states;
	UITableView *		_statesTableView;
	NSArray *			_units;
	
	BOOL				_closing;
	
	id<DamageViewControllerDelegate>	_delegate;
}

@property (nonatomic, retain) IBOutlet UITextField * HP;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray * attribLabels;
@property (nonatomic, retain) IBOutletCollection(UITextField) NSArray * attribValues;
@property (nonatomic, retain) IBOutlet UITableView * statesTableView;
@property (nonatomic, assign) id<DamageViewControllerDelegate> delegate;

+ (NSInteger) lastHP;
+ (void) setLastHP:(NSInteger)HP;

- (id) initWithUnits:(NSArray *)units;

- (IBAction) healButton:(id) sender;
- (IBAction) damageButton:(id) sender;
- (IBAction) selectState:(id) sender;

@end

@protocol DamageViewControllerDelegate

@required
- (void) addedDamageFromViewController:(DamageViewController *)damageView toUnits:(NSArray *)units;

@end

