//
//  ImageEditController.h
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageEditController : UIViewController

@property (nonatomic, strong) UIImage *displayImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageToEdit;

@end
