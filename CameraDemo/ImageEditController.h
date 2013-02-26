//
//  ImageEditController.h
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropView.h"
#import "ATMHud.h"
#import "ATMHudDelegate.h"

@protocol ImageEditDelegate <NSObject>

-(void)addAnotherPage:(NSMutableArray *)imagesArray;
-(void)finishedAddingPages:(NSMutableArray *)imagesArray;

@end

@interface ImageEditController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) UIImage *displayImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageToEdit;
@property (nonatomic, strong) CropView *cropView;
@property (nonatomic, unsafe_unretained) id<ImageEditDelegate> delegate;
@property (nonatomic, strong) ATMHud *hud;

- (IBAction)cropImage:(id)sender;
- (IBAction)retakeButton:(id)sender;
- (IBAction)closeButton:(id)sender;



@end
