//
//  TwitterTimelineViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 10/30/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TwitterTimelineViewController.h"

@interface TwitterTimelineViewController ()

@end

@implementation TwitterTimelineViewController

- (TwitterTimelineViewController *)initWithScreenName:(NSString *)screenName
{
    self = [super init];
    
    if (self) {
        self.screenName = screenName;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:self.screenName APIClient:client];
}

@end
