//
//  DMAvatarViewController.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/18/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMAvatarViewControllerDelegate;

@interface DMAvatarViewController : UITableViewController {
	UIImage*		_selectedIcon;
	UIImage*		_selectedAvatar;
	NSMutableArray*	_imageNames;
	NSMutableArray*	_avatars;
	NSString*		_selectedAvatarName;
	NSUInteger		_selectedAvatarIndex;
	NSUInteger		_rowCount;
	BOOL			_enumerate;
	id<DMAvatarViewControllerDelegate>	_delegate;
}

@property (nonatomic, assign) id<DMAvatarViewControllerDelegate> delegate;

- (id) initWithSelectedAvatar:(NSString*)avatarName;
@end

@protocol DMAvatarViewControllerDelegate <NSObject>

- (void) avatarViewController:(DMAvatarViewController*)avatarViewController selectedAvatar:(UIImage*)avatar named:(NSString*)avatarName;

@end

