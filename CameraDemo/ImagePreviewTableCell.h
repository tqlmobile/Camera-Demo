//
//  ImagePreviewTableCell.h
//  CameraDemo
//
//  Created by Total Quality Logistics on 4/18/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreviewTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *poNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *laneLabel;
@property (weak, nonatomic) IBOutlet UILabel *docTypeLabel;

@end
