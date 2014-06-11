//
//  DMTextEditView.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/10/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEModalView.h"
#import "DMTitleEditProtocol.h"

@protocol DMTextEditViewDelegate;

@interface DMTextEditView : SEModalView<UITextFieldDelegate>
{
	UITextField *	_title;
	UITextField *	_text;
	id				_delegate;
}

@property (nonatomic, retain) IBOutlet UITextField * title;
@property (nonatomic, retain) IBOutlet UITextField * text;
@property (nonatomic, assign) id<DMTextEditViewDelegate> delegate;

+ (DMTextEditView *) textEditViewWithTitle:(NSString *)title
						   titleIsReadOnly:(BOOL)readOnlyTitle
								  withText:(NSString *)text;

- (void)show;

- (IBAction) done;
- (IBAction) cancel;

@end

@protocol DMTextEditViewDelegate <DMTitleEditProtocol>

@required
- (void) textEditViewDone:(DMTextEditView *)textEditView withTitle:(NSString *)title withText:(NSString *)text;
- (void) textEditViewCancelled:(DMTextEditView *)textEditView;

@end
