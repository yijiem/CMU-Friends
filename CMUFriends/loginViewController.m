//
//  loginViewController.m
//  CMUFriends
//
//  Created by Yijie Ma on 4/23/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "loginViewController.h"
#import "homeTableViewController.h"

@interface loginViewController ()
@property (nonatomic, readonly, retain) IBOutlet UITextField *andrewIdTextField;
@property (nonatomic, readonly, retain) IBOutlet UITextField *password;
@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.andrewIdTextField.delegate = self;
    self.password.delegate = self;
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

- (IBAction)loginButtonTouch:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.andrewIdTextField.text password:self.password.text
                                    block:^(PFUser *user, NSError *error) {
                                    if (user) {
                                    // Do stuff after successful login.
                                        [self performSegueWithIdentifier:@"Login Success" sender:sender];
                                    } else {
                                    // The login failed. Check error to see why.
                                        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                          message:[error localizedDescription]
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"OK"
                                                                                otherButtonTitles:nil];
                                        [message show];
                                        self.andrewIdTextField.text = @"";
                                        self.password.text = @"";
                                    }
    }];
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Login Success"]) {
        if ([segue.destinationViewController isKindOfClass:[homeTableViewController class]]) {
            // do what you want to the next view
        }
    }
}
*/

@end
