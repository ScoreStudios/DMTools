//
//  DMStatusCell.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/17/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMStatusCell : UITableViewCell
{
	NSArray*	_buttons;
	NSArray*	_labels;
}

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray* buttons;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray* labels;

@end
