//
//  ImagePreviewController.h
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewController : UIViewController

@property (nonatomic,strong) NSMutableArray *arrayOfImages;

@property (unsafe_unretained, nonatomic) IBOutlet UINavigationItem *imagePreviewNavBar;
- (IBAction)backButton:(id)sender;


@end
