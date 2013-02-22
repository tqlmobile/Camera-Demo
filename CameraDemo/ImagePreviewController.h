//
//  ImagePreviewController.h
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewController : UIViewController
{
    NSMutableArray *_arrayOfImages;
}

@property (nonatomic,strong) NSMutableArray *arrayOfImages;

@property (weak, nonatomic) IBOutlet UITableView *imagesTableView;
- (IBAction)processDocuments:(id)sender;


@end
