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
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *departmentTextField;
@property (weak, nonatomic) IBOutlet UIView *genderView;
@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *departmentPicker;

@property (strong, nonatomic) NSArray *genderArray;
@property (strong, nonatomic) NSArray *departmentArray;
@end

@implementation signUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.andrewIdTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.facebookIdTextField.delegate = self;
    self.nameTextField.delegate = self;
    self.genderTextField.delegate = self;
    self.departmentTextField.delegate = self;
    
    self.genderArray = @[@"male", @"female", @"undisclose"];
    self.departmentArray = @[@"Electrical and Computer Engineering", @"Information Network Institute", @"Computer Science", @"Carnegie Institute of Technology", @"Tepper", @"Heinz", @"College of Fine Art"];
    /* hide the gender view */
    self.genderView.frame = CGRectMake(34, 600, 252, 149);
    /* hide the department view */
    self.departmentView.frame = CGRectMake(34, 600, 252, 149);
}


- (IBAction)departViewOKButtonTouch:(id)sender
{
    /* hide the department view */
    self.departmentView.frame = CGRectMake(34, 600, 252, 149);
}

- (IBAction)genderViewOKButtonTouch:(id)sender
{
    /* hide the gender view */
    self.genderView.frame = CGRectMake(34, 600, 252, 149);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    // Handle the selection
    if ([pickerView isEqual:self.genderPicker]) {
        self.genderTextField.text = self.genderArray[row];
    } else if ([pickerView isEqual:self.departmentPicker]) {
        self.departmentTextField.text = self.departmentArray[row];
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.genderPicker]) {
        return self.genderArray.count;
    } else if ([pickerView isEqual:self.departmentPicker]) {
        return self.departmentArray.count;
    }
    return 0;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    
    if ([pickerView isEqual:self.genderPicker]) {
        NSLog(@"In pickerView:titleForRow:genderPicker....");
        title = self.genderArray[row];
    } else if ([pickerView isEqual:self.departmentPicker]) {
        NSLog(@"In pickerView:titleForRow:departmentPicker....");
        title = self.departmentArray[row];
    }
    return title;
}

/* function: pickerView:viewForRow:forComponent:reusingView */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    
    if ([pickerView isEqual:self.genderPicker]) {
        NSLog(@"In pickerView:titleForRow:genderPicker....");
        retval.text = self.genderArray[row];
    } else if ([pickerView isEqual:self.departmentPicker]) {
        NSLog(@"In pickerView:titleForRow:departmentPicker....");
        retval.text = self.departmentArray[row];
    }
    retval.font = [UIFont systemFontOfSize:15];
    retval.textAlignment = NSTextAlignmentCenter;
    return retval;
}

/* do not show keyboard when hitting the gender textfield */
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.genderTextField])
    {
        [textField resignFirstResponder];
        // Show you custom picker here....
        NSLog(@"gender text field should begin editing....");
        /* show the gender picker view */
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.genderView.frame = CGRectMake(34, 375, 252, 149);
        [UIView commitAnimations];
        return NO;
    } else if ([textField isEqual:self.departmentTextField])
    {
        /* show department picker view*/
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.departmentView.frame = CGRectMake(34, 375, 252, 149);
        [UIView commitAnimations];
        return NO;
    }
    return YES;
}

// hide text keyboard of UITextField when done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButtonTouch:(id)sender
{
    PFUser *user = [PFUser user];
    user.username = self.andrewIdTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    
    // other fields can be set just like with PFObject
    user[@"facebookID"] = self.facebookIdTextField.text;
    user[@"name"] = self.nameTextField.text;
    // do not upload gender information if user select "undisclose"
    if (![self.genderTextField.text isEqual:@"undisclose"]){
        user[@"gender"] = self.genderTextField.text;
    }
    user[@"department"] = self.departmentTextField.text;
    user[@"availability"] = @YES;
    
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
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
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
