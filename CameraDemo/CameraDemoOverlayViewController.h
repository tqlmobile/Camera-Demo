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
-(void)done;

@end


@interface CameraDemoOverlayViewController : UIViewController
@property (nonatomic, unsafe_unretained) id <CameraOverlayDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *picturesTakenLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;


- (IBAction)cancelButton:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)Done:(id)sender;


@end
