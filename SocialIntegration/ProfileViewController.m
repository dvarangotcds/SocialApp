//
//  ProfileViewController.m
//  FacebookTest
//
//  Created by Juan Andrés Blanco on 10/29/15.
//  Copyright © 2015 Maximiliano Gaitán. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostViewController.h"
#import "FacebookFriendsTableViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginButton.delegate = self;
    //for more permissions visit https://developers.facebook.com/docs/facebook-login/permissions/v2.5
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_birthday"];

    //to know if the user is already logged in
    if (![FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"email, name, picture.type(large), birthday, friends"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [self setInfoWithDictionary:result];
             }
         }];
    }

}

#pragma mark - delegate methods

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    self.userName.text = @"";
    self.userBirthday.text = @"";
    self.userMail.text = @"";    
    self.userProfilePic.image = nil;
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    __weak ProfileViewController *wself = self;
    if (!result.isCancelled) {
        if (!error) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                               parameters:@{@"fields" : @"email, name, picture.type(large), birthday, friends"}]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     [wself setInfoWithDictionary:result];
                 }
             }];
        }
    }
}

#pragma mark - UI Actions

- (IBAction)shareURLAction:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSString *title = @"Title";
    NSString *description = @"Description";
    [self facebookShareUrl:url title:title description:description imageURL:nil];
    
}

- (IBAction)showFriends:(id)sender
{
    FacebookFriendsTableViewController *friendsVC = [[FacebookFriendsTableViewController alloc] init];
    [self showViewController:friendsVC sender:nil];
}

#pragma mark - Private methods
// Displays a share dialog to share a link. image can be nil.
// Have in mind that if the URL you share has its own open graph info, it may override the title, description and image you provide here.
// You can check information on the link here: https://developers.facebook.com/tools/debug/ 
- (void)facebookShareUrl:(NSURL *)url title:(NSString *)title description:(NSString *)description imageURL:(NSURL *)imageURL
{
    FBSDKShareLinkContent *shareContent = [[FBSDKShareLinkContent alloc] init];
    [shareContent setContentTitle:title];
    [shareContent setContentURL:url];
    [shareContent setContentDescription:description];
    [shareContent setImageURL:imageURL];
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];

    // This is to determine if Facebook App is installed on the device. FBSDKShareDialogModeNative will only work on Facebook App
    // You can also use FBSDKShareDialogModeAutomatic
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        dialog.mode = FBSDKShareDialogModeNative;
    } else {
        dialog.mode = FBSDKShareDialogModeWeb;
    }
    
    dialog.shareContent = shareContent;
    [dialog show];
}

- (void)setInfoWithDictionary:(NSDictionary *)dict
{
    NSLog(@"result: %@", dict);
    
    self.userName.text = [dict objectForKey:@"name"];
    self.userBirthday.text = [dict objectForKey:@"birthday"];
    self.userMail.text = [dict objectForKey:@"email"];
    
    NSString *imageString = [[[dict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
    NSURL *url = [[NSURL alloc] initWithString:imageString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *tmpImage = [[UIImage alloc] initWithData:data];
    self.userProfilePic.image = tmpImage;
}

@end
