//
//  CameraDemoOverlayViewController.h
//  CameraDemo
//
//  Created by Casey Tritt on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CameraOverlayDelegate <NSObject>

-(void)cancel;
-(void)takePicture;

@end


@interface CameraDemoOverlayViewController : UIViewController
@property (nonatomic, unsafe_unretained) id <CameraOverlayDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *picturesTakenLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancelButton:(id)sender;
- (IBAction)takePicture:(id)sender;

@end
