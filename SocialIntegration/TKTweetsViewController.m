//
//  TKTweetsViewController.m
//  SocialIntegration
//
//  Created by Santiago Rama on 11/2/15.
//  Copyright © 2015 Diego Varangot. All rights reserved.
//

#import "TKTweetsViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "TKTimelineViewController.h"

@interface TKTweetsViewController ()

@property (weak, nonatomic) IBOutlet TWTRTweetView *tweetView;
@property (weak, nonatomic) IBOutlet UITextField *tweetIdTextField;

@property (weak, nonatomic) IBOutlet UITextField *searchQueryTextField;

@end

@implementation TKTweetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTweetView];
}

- (void)setupTweetView
{
    // If you need to initialize your tweet view programatically you can do it like this
    // TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:nil style:TWTRTweetViewStyleRegular];
    
    self.tweetView.showActionButtons = YES;
    self.tweetView.theme = TWTRTweetViewThemeLight;
}

# pragma mark - UI Actions

- (IBAction)loadTweetAction:(id)sender
{
    [self loadTweetWithID:self.tweetIdTextField.text];
}

// To create a tweet. This presents a dialog to compose and send a tweet.
// This includes a menu for the user to select which of the logged accounts (in the device) will send the tweet.
// Reference: https://docs.fabric.io/ios/twitter/compose-tweets.html
- (IBAction)composeTweetAction:(id)sender
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:@"Some default text"];
    [composer setImage:[UIImage imageNamed:@"fabric"]];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
    
}

- (IBAction)composeTweetWithAppCard:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"fabric"];
    TWTRCardConfiguration *card = [TWTRCardConfiguration appCardConfigurationWithPromoImage:image iPhoneAppID:@"12345" iPadAppID:nil googlePlayAppID:nil];
    TWTRComposerViewController *composerWithCard = [[TWTRComposerViewController alloc] initWithUserID:[[[Twitter sharedInstance] sessionStore] session].userID cardConfiguration:card];
    // Show the view controller
    [self showDetailViewController:composerWithCard sender:self];
    
}

// This method receives the tweet id and makes the API call to get a TWTRTweet object that represents the tweet.
// Then it displays the tweet in a previously created TWTRTweetView
// You also have the tweet info in the TWTRTweet object
// TWTRTweet reference: https://dev.twitter.com/twitter-kit/ios-reference/twtrtweet
// TWTRTweetView reference: https://dev.twitter.com/twitter-kit/ios-reference/twtrtweetview
- (void)loadTweetWithID:(NSString *)tweetID
{
    __weak TKTweetsViewController *wself = self;
    
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    [client loadTweetWithID:tweetID completion:^(TWTRTweet *tweet, NSError *error) {
        if (tweet) {
            [wself.tweetView configureWithTweet:tweet];
        } else {
            NSLog(@"Failed to load tweet: %@", [error localizedDescription]);
        }
    }];

    //If you need to load more than one tweet you can pass an array and use loadTweetsWithIDs:completion:
    NSArray *tweetIDs = @[@"20", @"510908133917487104"];
    [client loadTweetsWithIDs:tweetIDs completion:^(NSArray *tweets, NSError *error) {
        NSLog(@"Tweets %@, Error: %@", tweets, error);
    }];
}

// This is an example of a manually created request to the API.
// More on creating requests: https://docs.fabric.io/ios/twitter/access-rest-api.html#constructing-a-twitter-request-manually
// Twitter REST API reference: https://dev.twitter.com/rest/public
- (IBAction)showFriendsAction:(id)sender
{

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"View Timeline"]) {
        TKTimelineViewController *vc = [segue destinationViewController];
        vc.searchQuery = self.searchQueryTextField.text;
    }
}

@end
