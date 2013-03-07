//
//  ProcessDocsViewController.h
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/21/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ASIHTTPRequest.h"
#import "Base64.h"

@interface ProcessDocsViewController : UIViewController <ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSMutableArray *allDocsArray;

@end
