//
//  SESettingsViewController.h
//  DM Tools
//
//  Created by hamouras on 4/2/11.
//  Copyright 2011 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SESettings;

@interface SESettingsViewCell : UITableViewCell {
@private
	UIControl*	_control;
}

@property (nonatomic, retain) UIControl* control;
@end

@interface SESettingsViewController : UITableViewController<UITextFieldDelegate> {
@protected
	SESettings *	_settings;
}

- (id) initWithCoder:(NSCoder *)decoder settings:(SESettings *)settings;

@end
