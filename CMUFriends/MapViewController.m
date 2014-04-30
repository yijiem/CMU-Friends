//
//  MapViewController.m
//  CMUFriends
//
//  Created by ZHANG YU on 4/27/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import "MapViewController.h"

// added by yu zhang. For provide map service.
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// added by yu zhang, for provide the parse service.
#import <Parse/Parse.h>

@interface LocationViewController : UIViewController
<CLLocationManagerDelegate>
@end

@interface MapViewController ()


@end

@implementation MapViewController

// added by yu zhang. For display all the friends nearby.
@synthesize sortedNearByPeople;

// added by yu zhang, to display two friends.
@synthesize userIndex;

CLLocationCoordinate2D coordinate;

// if it is the first time of get location, focus the area.
bool firstLoad;


// change the display type to satellite and stand.
- (IBAction)changeMapType:(id)sender {
    
    if (_mapView.mapType == MKMapTypeStandard)
        _mapView.mapType = MKMapTypeSatellite;
    else
        _mapView.mapType = MKMapTypeStandard;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        firstLoad = YES;
    }
    return self;
}

// set the range and display the location.
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (firstLoad == YES) {
        [self showLocationOfFriendAndMe];
        firstLoad = NO;
    }
}

// added by yu zhang begin.
// when press the button of "show nearby friends", show all the friends nearby.
- (IBAction)showNearByFriend:(id)sender {
    // when userIndex = -1, it means that only show two person.
    if (sortedNearByPeople == NULL) {
        return;
    }
    
    for (PFUser *user in sortedNearByPeople) {
        
        // Add an annotation2
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        PFGeoPoint *location = [user objectForKey:@"location"];
        
        point.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        point.title = [user objectForKey:@"name"];
        point.subtitle = [user objectForKey:@"gender"];
        
        //point.pinColor = MKPinAnnotationColorPurple;
        
        [self.mapView addAnnotation:point];
        
    }
}
// added by yu zhang end.

// Show the location of my friend and me.
// Also focus the area to be my standing place.
- (void)showLocationOfFriendAndMe
{
    coordinate = _mapView.userLocation.location.coordinate;
    
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude + 0.05);
    
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:coordinate2 addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    // Add an annotation2
    MKPointAnnotation *point2 = [[MKPointAnnotation alloc] init];
    point2.coordinate = coordinate2;
    point2.title = @"Bin Feng";
    point2.subtitle = @"The location of the friend.";
    
    [self.mapView addAnnotation:point2];
    
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            [self.mapView addOverlay:line];
            NSLog(@"Rout Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            //NSLog(@"Total Steps : %d",[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Rout Instruction : %@",[obj instructions]);
                NSLog(@"Rout Distance : %f",[obj distance]);
            }];
        }];
    }];
    
    // focus the area to myself.
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // show the location of the user.
    _mapView.showsUserLocation = YES;
    
    // send a log.
    NSLog(@"MapViewController says hello");
    
    firstLoad = YES;
    
    // set the mapView to show the location.
    [self.mapView setDelegate:self];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    // the callback function to show the route between two person.
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* aView = [[MKPolylineView alloc]initWithPolyline:(MKPolyline*)overlay] ;
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        aView.lineWidth = 10;
        
        return aView;
    }
    
    return nil;
}

// focus the area to my place.
- (IBAction)zoomIn:(id)sender {
    // focus the area to myself.
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
