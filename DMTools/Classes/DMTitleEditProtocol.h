//
//  DMTitleEditProtocol.h
//  DM Tools
//
//  Created by Dimitrios Chamouratidis on 2/10/12.
//  Copyright (c) 2012 Score Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMTitleEditProtocol <NSObject>
@optional
- (BOOL) editView:(UIView *)editView isValidTitle:(NSString*)title;
@end
