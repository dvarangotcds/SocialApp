//
//  PostViewController.h
//  FacebookTest
//
//  Created by Juan Andrés Blanco on 10/30/15.
//  Copyright © 2015 Maximiliano Gaitán. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface PostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textPost;

@end
