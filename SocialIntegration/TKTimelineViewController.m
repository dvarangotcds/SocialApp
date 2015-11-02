//
//  TKTimelineViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 10/30/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TKTimelineViewController.h"

@interface TKTimelineViewController ()

@end

@implementation TKTimelineViewController

- (TKTimelineViewController *)initWithSearchQuery:(NSString *)searchQuery
{
    self = [super init];
    
    if (self) {
        self.searchQuery = searchQuery;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.searchQuery;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:self.searchQuery APIClient:client];
}

@end
