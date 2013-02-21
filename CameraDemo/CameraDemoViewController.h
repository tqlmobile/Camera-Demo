//
//  CameraDemoViewController.h
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/19/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import "CameraDemoOverlayViewController.h"
#import "ImagePreviewController.h"

@interface CameraDemoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,CameraOverlayDelegate>

@property (strong, nonatomic) UIImagePickerController *cameraUI;
@property (strong, nonatomic) CameraDemoOverlayViewController *overlay;
@property (strong, nonatomic) NSMutableArray *picsArray;
@property (strong, nonatomic) ImagePreviewController *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *openPhotosButton;


- (IBAction)openCamera:(id)sender;
- (IBAction)openPhotos:(id)sender;




@end
