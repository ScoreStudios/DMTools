//
//  DMPickerEditView.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/8/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEModalView.h"
#import "DMTitleEditProtocol.h"

@protocol DMPickerEditViewDelegate;

@interface DMPickerEditView : SEModalView<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
	UITextField *	_title;
	UIPickerView *	_picker;
	id				_delegate;
	NSArray*		_items;
	enum
	{
		ItemTypeImage = 0,
		ItemTypeString
	} _itemType;
}

@property (nonatomic, retain) IBOutlet UITextField * title;
@property (nonatomic, retain) IBOutlet UIPickerView * picker;
@property (nonatomic, assign) id<DMPickerEditViewDelegate> delegate;

+ (DMPickerEditView *) pickerEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
									withImages:(NSArray*)images
							 withSelectedIndex:(NSUInteger)selectedIndex;
+ (DMPickerEditView *) pickerEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
								   withStrings:(NSArray*)strings
							 withSelectedIndex:(NSUInteger)selectedIndex;

- (void)show;

- (IBAction) done;
- (IBAction) cancel;

@end

@protocol DMPickerEditViewDelegate <DMTitleEditProtocol>

@required
- (void) pickerEditViewDone:(DMPickerEditView *)pickerEditView withTitle:(NSString *)title withSelectedIndex:(NSUInteger)selectedIndex;
- (void) pickerEditViewCancelled:(DMPickerEditView *)pickerEditView;

@end
