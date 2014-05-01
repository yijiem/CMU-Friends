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

#import "ZSAnnotation.h"

#import "UIKit/UIColor.h"
#import "UIKit/UIInterface.h"

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

@synthesize searchNearby;
@synthesize zoomIn;

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
        firstLoad = NO;
        if (userIndex == -1) {
            [self zoomIn:zoomIn];
        } else {
            [self showLocationOfFriendAndMe];
        }
    }
}

//- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
//    
//    // Don't mess with user location
//    if(![annotation isKindOfClass:[ZSPinAnnotation class]])
//        return nil;
//    
//    ZSPinAnnotation *a = (ZSPinAnnotation *)annotation;
//    static NSString *defaultPinID = @"StandardIdentifier";
//    
//    // Create the ZSPinAnnotation object and reuse it
//    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//    if (pinView == nil){
//        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//    }
//    
//    // Set the type of pin to draw and the color
//    pinView.annotationType = ZSPinAnnotationTypeStandard;
//    pinView.annotationColor = a.color;
//    pinView.canShowCallout = YES;
//    
//    return pinView;
//    
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // Don't mess with user location
    if(![annotation isKindOfClass:[ZSAnnotation class]])
        return nil;
    
    ZSAnnotation *a = (ZSAnnotation *)annotation;
    static NSString *defaultPinID = @"StandardIdentifier";
    
    // Create the ZSPinAnnotation object and reuse it
    ZSPinAnnotation *pinView = (ZSPinAnnotation *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil){
        pinView = [[ZSPinAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    
    // Set the type of pin to draw and the color
    pinView.annotationType = ZSPinAnnotationTypeStandard;
    pinView.annotationColor = a.color;
    pinView.canShowCallout = YES;
    
    return pinView;
}

// added by yu zhang begin.
// when press the button of "show nearby friends", show all the friends nearby.
- (IBAction)showNearByFriend:(id)sender {
    // when userIndex = -1, it means that only show two person.
    if (sortedNearByPeople == NULL) {
        return;
    }
    
    for (PFUser *user in sortedNearByPeople) {
        [self addAnnotationFriend:user];
    }
}

// added by yu zhang. To add a user into the map.
-(CLLocationCoordinate2D)addAnnotationFriend: (PFUser*)user {
    // Add an annotation2
//    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
//    PFGeoPoint *location = [user objectForKey:@"location"];
//    
//    if (location == NULL) {
//        //return 0;
//        NSLog(@"The location is null!");
//        // don't know how to deal with this. give a 0,0 position back.
//        return CLLocationCoordinate2DMake(0,0);
//    }
//    
//    CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
//    point.coordinate = userCoordinate;
//    point.title = [user objectForKey:@"name"];
//    point.subtitle = [user objectForKey:@"gender"];

    ZSAnnotation *point = [[ZSAnnotation alloc] init];
    PFGeoPoint *location = [user objectForKey:@"location"];
    
    if (location == NULL) {
        //return 0;
        NSLog(@"The location is null!");
        // don't know how to deal with this. give a 0,0 position back.
        return CLLocationCoordinate2DMake(0,0);
    }
    
    CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    point.coordinate = userCoordinate;
    point.title = [user objectForKey:@"name"];
    point.subtitle = [user objectForKey:@"gender"];
    
    // change the color of the pins.
    if ([point.subtitle  isEqual: @"male"]) {
        point.color = [UIColor blueColor];
    } else if ([point.subtitle  isEqual: @"female"]) {
        point.color = [UIColor redColor];
    } else {
        point.color = [UIColor purpleColor];
    }
    
    //point.pinColor = MKPinAnnotationColorPurple;
    
    [self.mapView addAnnotation:point];
    
    return userCoordinate;
}

// added by yu zhang end.

// Show the location of my friend and me.
// Also focus the area to be my standing place. If route not found, foucus to the friend's location.
- (void)showLocationOfFriendAndMe
{
    // do not need to show if their is no index of friend.
    if (userIndex == -1) {
        return;
    }
    
    coordinate = _mapView.userLocation.location.coordinate;
    
    /* get user object on the selected row, then add a annotation to it. */
    PFUser *user = (PFUser *) [self.sortedNearByPeople objectAtIndex:userIndex];
    
    // Add an annotation2 and get the location.
    CLLocationCoordinate2D friendCoordinate = [self addAnnotationFriend:user];
    
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:friendCoordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    __block CLLocationDistance totalDistance = 0;
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSLog(@"response = %@",response);
        
        if (response == NULL) {
            // focus the area to friend.
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (friendCoordinate, 0, 0);
            [_mapView setRegion:region animated:NO];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"No route found"
                                  message: @"Failed to find the route."\
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        
        
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            [self.mapView addOverlay:line];
            NSLog(@"Rout Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            totalDistance = rout.distance;
            
            NSArray *steps = [rout steps];
            
            //NSLog(@"Total Steps : %d",[steps count]);
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Rout Instruction : %@",[obj instructions]);
                // The route distance in meters. (read-only)
                NSLog(@"Rout Distance : %f",[obj distance]);
            }];
            
            // focus the area to myself.
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, totalDistance*2.2, totalDistance*2.2);
            [_mapView setRegion:region animated:NO];
            

        }];
    }];
    
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
    
    if (userIndex == -1) {
        // when initialize, just call this function to show all the friends.
        [self showNearByFriend:searchNearby];
    }
    
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
    coordinate = _mapView.userLocation.location.coordinate;
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
