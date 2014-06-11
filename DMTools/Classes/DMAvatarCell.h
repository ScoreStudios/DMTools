//
//  DMIconSelectCell.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/18/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMAvatarCell : UITableViewCell
{
	NSArray*	_avatars;
}

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray* avatars;

@end
