//
//  TwitterTimelineViewController.h
//  SocialIntegration
//
//  Created by Santiago Rama on 10/30/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import <TwitterKit/TwitterKit.h>

@interface TwitterTimelineViewController : TWTRTimelineViewController

@property (nonatomic, strong) NSString *screenName;

- (TwitterTimelineViewController *)initWithScreenName:(NSString *)screenName;

@end
