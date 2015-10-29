//
//  FriendTableViewCell.m
//  SocialIntegration
//
//  Created by Diego Varangot on 10/27/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "FriendTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FriendTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setImageWithURL:(NSURL *)imageURL
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        [self.image sd_setImageWithURL:imageURL];
    });
}

@end
