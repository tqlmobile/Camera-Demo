//
//  CameraDemoOverlayViewController.m
//  CameraDemo
//
//  Created by Casey Tritt on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "CameraDemoOverlayViewController.h"

@interface CameraDemoOverlayViewController ()

@end

@implementation CameraDemoOverlayViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender
{
    [self.delegate cancel];
}

- (IBAction)takePicture:(id)sender
{
    [self.delegate takePicture];
}

- (IBAction)Done:(id)sender
{
    [self.delegate done];
}
- (void)viewDidUnload {
    [self setPicturesTakenLabel:nil];
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}
@end
