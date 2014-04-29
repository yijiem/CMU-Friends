//
//  signUpViewController.m
//  CMUFriends
//
//  Created by Yijie Ma on 4/27/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "signUpViewController.h"
#import <Parse/Parse.h>

@interface signUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *andrewIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *facebookIdTextField;
@end

@implementation signUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.andrewIdTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.facebookIdTextField.delegate = self;
}

// hide text keyboard of UITextField when done
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButtonTouch:(id)sender {
    PFUser *user = [PFUser user];
    user.username = self.andrewIdTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    // other fields can be set just like with PFObject
    user[@"facebookID"] = self.facebookIdTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            [self performSegueWithIdentifier:@"Register Success" sender:sender];
            // [self shouldPerformSegueWithIdentifier:@"YES" sender:NULL];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                              message:errorString
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            self.andrewIdTextField.text = @"";
            self.emailTextField.text = @"";
            // do not perform segue
            // [self shouldPerformSegueWithIdentifier:@"NO" sender:NULL];
        }
    }];
}

// use to prevent segue from happening
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"NO"]) {
        return NO;
    } else {
        return YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
