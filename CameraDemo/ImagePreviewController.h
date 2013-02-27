//
//  ImagePreviewController.h
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageEditController.h"

@interface ImagePreviewController : UIViewController <ImageEditDelegate, UIAlertViewDelegate>
{
    NSMutableArray *_arrayOfImages;
}

@property (nonatomic,strong) NSMutableArray *arrayOfImages;

@property (weak, nonatomic) IBOutlet UITableView *imagesTableView;
- (IBAction)processDocuments:(id)sender;
- (IBAction)addAnotherPage:(id)sender;
- (IBAction)cancelButton:(id)sender;

@end
