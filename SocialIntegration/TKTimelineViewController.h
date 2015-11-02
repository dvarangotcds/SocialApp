//
//  TKTimelineViewController.h
//  SocialIntegration
//
//  Created by Santiago Rama on 10/30/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import <TwitterKit/TwitterKit.h>

@interface TKTimelineViewController : TWTRTimelineViewController

@property (nonatomic, strong) NSString *searchQuery;

- (TKTimelineViewController *)initWithSearchQuery:(NSString *)searchQuery;

@end
