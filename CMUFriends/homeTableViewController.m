//
//  homeTableViewController.m
//  CMUFriends
//
//  Created by Yijie Ma on 4/28/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "homeTableViewController.h"
#import "NearByPeople.h"
#import "ProfileViewController.h"

// added by yu zhang. To transfer the data from homeTableView to MapViewController.
#import "MapViewController.h"

@interface homeTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIImageView *shakeImageView;
@end

@implementation homeTableViewController

/* Functions related to shaking including shaking sound effect, shaking animation, shaking motion handler */
/* play shake sound when shaking */
-(void) playSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    // [soundPath release];
    // NSLog(@"soundpath retain count: %lu", (unsigned long)[soundPath retainCount]);
}


/* let this view become the first responder of motion */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
}


/* Handling shaking motion */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        // User was shaking the device. Post a notification named "shake."
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
        [self playSound];
        [self startShake:self.shakeImageView];
        [self refresh]; // update near by friends' data
    }
}

/* shake animation */
- (void)startShake:(UIView *)view
{
    CGAffineTransform leftShake = CGAffineTransformMakeTranslation(-5, 0);
    CGAffineTransform rightShake = CGAffineTransformMakeTranslation(5, 0);
    
    view.transform = leftShake;  // starting point
    
    [UIView beginAnimations:@"shake_image" context:(__bridge void *)(view)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.08];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shakeEnded:finished:context:)];
    
    view.transform = rightShake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)shakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue]) {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}


/* refresh icon at the top of the table view */
- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
# warning block the main thread
    [self update];
    [self.myTableView reloadData];
    [self.refreshControl endRefreshing];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // when press the button "Show in the map", perform this to transfer the data to another
    // view controller.
    if([segue.identifier isEqualToString:@"fromShowInMapToMap"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.sortedNearByPeople = self.sortedNearByPeople;
        controller.userIndex = -1;
        return;
    }
    
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"select a cell"]) {
                if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
                    ProfileViewController *pvc = (ProfileViewController *) segue.destinationViewController;
                    
                    // modified by yu zhang.
                    // transfer a array and a index to next view.
                    pvc.sortedNearByPeople = self.sortedNearByPeople;
                    pvc.userIndex = indexPath.row;
                }
            }
        }
    }
}

// added by yu zhang, when press the button of 
- (IBAction)showPeopleInMap:(id)sender {
    
    // display a 
    NSLog(@"GO TO THE MAP.");
}

/* every time user load the home view or pull down the table list will call update() */
- (void)update
{
    /* report current user's location to back-end when user login in */
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
    
    /* query User object from back-end except the current user */
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    NSArray *objects = [query findObjects];
    
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            NSLog(@"Before sorting by distance");
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
            
            /* generate sorted near by people array for display */
            self.sortedNearByPeople = [NearByPeople sortByDistance:objects targetedLocation:[[PFUser currentUser] objectForKey:@"location"]];
            
            NSLog(@"After sorting by distance");
            for (PFObject *object in self.sortedNearByPeople) {
                NSLog(@"%@", object.objectId);
            }
            
            /* generate sorted distance array for display */
            self.distance = [NearByPeople calculateDistance:self.sortedNearByPeople targetedLocation:[[PFUser currentUser] objectForKey:@"location"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:self.refreshControl];
    [self update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"sortedNearByPeople.count = %lu", (unsigned long)self.sortedNearByPeople.count);
    return self.sortedNearByPeople.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show distance"
                             forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"show distance"];
    }
    
    cell.textLabel.text =
    [NSString stringWithFormat:@"%@", [[self.sortedNearByPeople objectAtIndex:indexPath.row] objectForKey:@"username"]];
    
    NSNumber *oneMile = [NSNumber numberWithDouble:1.0];
    //NSNumber *fiveMile = [NSNumber numberWithDouble:5.0];
    //NSNumber *tenMile = [NSNumber numberWithDouble:10.0];
    //NSNumber *hundredMile = [NSNumber numberWithDouble:100.0];
    
    NSNumber *distance = [NSNumber numberWithDouble:[[self.distance objectAtIndex:indexPath.row] doubleValue]];
    
    // modified by yu zhang to display meters.
    if ([[self.distance objectAtIndex:indexPath.row] compare:oneMile] == NSOrderedAscending) {
        //cell.detailTextLabel.text = @"less than one mile...";
        double distanceMeter = [distance doubleValue]*1600;
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%.1f meters", distanceMeter];

    } else {
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%.1f miles", [distance doubleValue]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
