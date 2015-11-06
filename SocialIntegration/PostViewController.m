//
//  PostViewController.m
//  FacebookTest
//
//  Created by Juan Andrés Blanco on 10/30/15.
//  Copyright © 2015 Maximiliano Gaitán. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()

@end

@implementation PostViewController

// You need publish_actions permission to post a status on facebook.
// This requires App review by Facebook. If not reviewed, only the app developers (https://developers.facebook.com/apps/-app-id-/roles/) will be able to post
// https://developers.facebook.com/docs/facebook-login/permissions/v2.5#reference-publish_actions

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Now we need publish_actions permissions to post.
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"]
                               fromViewController:self
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                              NSLog(@"texto de resultado: %@",result);
                                              NSLog(@"texto de error: %@",error);
                                          }];
        
    }
}

#pragma mark - UI Actions

- (IBAction)cancelAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)postIt:(id)sender
{
    NSString *msg = self.textPost.text;
    NSDictionary *params = @{
                             @"message": msg,
                             };
    /* make the API call */
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/feed"
                                  parameters:params
                                  HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        NSLog(@"%@", result);
        if(!error){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Great!"
                                                                           message:@"You post that on Facebook!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok!"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ohhh!"
                                                                           message:@"Something just happend! Try posting later!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok!"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
