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

@end

@implementation homeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)refresh:(id)sender
{
    [self.refreshControl beginRefreshing];
# warning block the main thread
    [self update];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


// added by yu zhang.



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // when press the button "Show in the map", perform this.
    if([segue.identifier isEqualToString:@"fromShowInMapToMap"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.sortedNearByPeople = NULL;
        return;
    }
    
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"select a cell"]) {
                if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
                    ProfileViewController *pvc = (ProfileViewController *) segue.destinationViewController;
                    /* get user object on the selected row */
                    PFUser *user = (PFUser *) [self.sortedNearByPeople objectAtIndex:indexPath.row];
                    
                    /* set up profile image */
                    PFFile *theImage = [user objectForKey:@"image"];
                    NSData *imageData = [theImage getData];
                    UIImage *image = [UIImage imageWithData:imageData];
                    pvc.profileImage = image;
                    
                    /* set up name, gender, facebookid, email */
                    pvc.profileName =
                    [NSString stringWithFormat:@"%@", [user objectForKey:@"name"]];
                    pvc.profileGender =
                    [NSString stringWithFormat:@"%@", [user objectForKey:@"gender"]];
                    pvc.facebookID =
                    [NSString stringWithFormat:@"%@", [user objectForKey:@"facebookID"]];
                    pvc.profileEmail =
                    [NSString stringWithFormat:@"%@", [user objectForKey:@"email"]];
                    pvc.profileDepartment =
                    [NSString stringWithFormat:@"%@", [user objectForKey:@"department"]];
                    
                }
            }
        }
    }
}



// added by yu zhang, when press the button of 
- (IBAction)showPeopleInMap:(id)sender {
    
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
    [self.refreshControl beginRefreshing];
    [self update];
    [self.refreshControl endRefreshing];
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
    
    if ([[self.distance objectAtIndex:indexPath.row] compare:oneMile] == NSOrderedAscending) {
        cell.detailTextLabel.text = @"less than one mile...";
    } else {
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%.1f miles...", [distance doubleValue]];
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
