//
//  FriendTableViewCell.h
//  SocialIntegration
//
//  Created by Diego Varangot on 10/27/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *socialIdentifier;

- (void)setImageWithURL:(NSURL *)imageURL;

@end
