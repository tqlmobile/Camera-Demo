//
//  ImageEditController.m
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "ImageEditController.h"

@interface ImageEditController ()

@end

@implementation ImageEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    //self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageToEdit.image = self.displayImage;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

     - (void)viewDidUnload {
         [self setImageToEdit:nil];
         [super viewDidUnload];
     }
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}
@end
