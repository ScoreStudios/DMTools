//
//  SEPushPopViewControllerProtocol.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 5/11/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SEPushPopViewControllerProtocol <NSObject>

- (void)willBePushedByNavigationController:(UINavigationController *)navigationController;
- (void)willBePoppedByNavigationController:(UINavigationController *)navigationController;

@end
