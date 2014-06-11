//
//  DMTableViewCell.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/9/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMTableViewCellDelegate;

@interface DMTableViewCell : UITableViewCell
{
	UIButton*					_button;
	id<DMTableViewCellDelegate>	_delegate;
}

@property (nonatomic, retain) UIControl* control;
@property (nonatomic, assign, getter=isImageViewInteractive) BOOL imageViewInteractive;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id<DMTableViewCellDelegate>)delegate;

@end

@protocol DMTableViewCellDelegate

- (void) tableViewCellImageAction:(DMTableViewCell*)tableViewCell;

@end