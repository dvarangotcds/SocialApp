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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        // TODO: publish content.
    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"]
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                              NSLog(@"texto de resultado: %@",result);
                                              NSLog(@"texto de error: %@",error);
                                          }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelAction:(id)sender {
    [self performSegueWithIdentifier:@"showProfileAgain" sender:self];
}

- (IBAction)postIt:(id)sender {
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
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Great!"
                                          message:@"You post that on Facebook!"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Ok!"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [self performSegueWithIdentifier:@"showProfileAgain" sender:self];
                                 }];
            
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Ohhh!"
                                          message:@"Something just happend! Try posting later!"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Ok!"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [self performSegueWithIdentifier:@"showProfileAgain" sender:self];
                                 }];
            
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}

@end
