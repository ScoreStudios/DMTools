//
//  DMNumberEditView.h
//  DM Tools
//
//  Created by hamouras on 23/09/2010.
//  Copyright 2010 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEModalView.h"
#import "DMTitleEditProtocol.h"

@protocol DMNumberEditViewDelegate;

@interface DMNumberEditView : SEModalView<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
	UITextField *			_title;
	UISegmentedControl *	_modeSelector;
	UIPickerView *			_picker;
	id						_delegate;
	NSInteger				_originalModifier;
	enum
	{
		ModeCounter,
		ModeValue,
		ModeValueModifier
	} _mode;
}

@property (nonatomic, retain) IBOutlet UITextField * title;
@property (nonatomic, retain) IBOutlet UISegmentedControl * modeSelector;
@property (nonatomic, retain) IBOutlet UIPickerView * picker;
@property (nonatomic, assign) id<DMNumberEditViewDelegate> delegate;

+ (DMNumberEditView *) numberEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
								   withCounter:(NSInteger)counter;
+ (DMNumberEditView *) numberEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
									 withValue:(NSInteger)value;
+ (DMNumberEditView *) numberEditViewWithTitle:(NSString *)title
							   titleIsReadOnly:(BOOL)readOnlyTitle
									 withValue:(NSInteger)value
								  withModifier:(NSInteger)modifier
							   hasModeSelector:(BOOL)hasModeSelector;

- (void)show;

- (IBAction) done;
- (IBAction) cancel;
- (IBAction) modeChanged;

@end

@protocol DMNumberEditViewDelegate <DMTitleEditProtocol>

@required
- (void) numberEditViewDone:(DMNumberEditView *)numberEditView withTitle:(NSString *)title withValue:(NSInteger)value withModifier:(NSInteger)modifier;
- (void) numberEditViewCancelled:(DMNumberEditView *)numberEditView;

@end
