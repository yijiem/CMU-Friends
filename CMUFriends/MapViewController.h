//
//  MapViewController.h
//  CMUFriends
//
//  Created by ZHANG YU on 4/27/14.
//  Copyright (c) 2014 cmu.08723.topcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

// added by yu zhang for map service.
#import "MapKit/MapKit.h"


@interface MapViewController : UIViewController
<MKMapViewDelegate>
// declare the class as implementing the <MKMapViewDelegate>protocol.


@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)zoomIn:(id)sender;
- (IBAction)changeMapType:(id)sender;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *zoomIn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeMapType;


@end
