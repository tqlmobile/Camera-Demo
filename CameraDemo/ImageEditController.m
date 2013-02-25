//
//  ImageEditController.m
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "ImageEditController.h"
#import "ImagePreviewController.h"
#import <QuartzCore/QuartzCore.h>

#define kResizeThumbSize 45

@interface ImageEditController ()
{
    CGPoint touchStart;
    BOOL isResizingLR;
    BOOL isResizingUL;
    BOOL isResizingUR;
    BOOL isResizingLL;
    BOOL isResizingLeft;
    BOOL isResizingRight;
    BOOL isResizingTop;
    BOOL isResizingBottom;
    CIContext *context;
}

@end

@implementation ImageEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *)picsArray
{
    if (_picsArray == nil)
    {
        _picsArray = [[NSMutableArray alloc]init];
    }
    return _picsArray;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:FALSE];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStyleBordered target:self action:@selector(cropImage)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageToEdit.image = self.displayImage;
    CGRect frame;
    frame = self.imageToEdit.bounds;
    frame = CGRectInset(frame, 10, 10);
    self.cropView = [[CropView alloc]initWithFrame:frame];
    self.cropView.multipleTouchEnabled = TRUE;
    self.cropView.layer.borderColor = [[UIColor orangeColor] CGColor];
    self.cropView.layer.borderWidth = 5.0;
    self.cropView.backgroundColor = [UIColor clearColor];
    self.cropView.alpha = 0.4;
    self.cropView.userInteractionEnabled = TRUE;
    [self.imageToEdit addSubview:self.cropView];
    //[self.view bringSubviewToFront:self.cropView];
    
    context = [CIContext contextWithOptions:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setImageToEdit:nil];
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    touchStart = [[touches anyObject] locationInView:self.cropView];
   
    isResizingUR = (self.cropView.bounds.size.width-touchStart.x < kResizeThumbSize && touchStart.y<kResizeThumbSize);
    isResizingUL = (touchStart.x <kResizeThumbSize && touchStart.y <kResizeThumbSize);
    isResizingLR = (self.cropView.bounds.size.width - touchStart.x < kResizeThumbSize && self.cropView.bounds.size.height - touchStart.y < kResizeThumbSize);
    isResizingLL = (touchStart.x <kResizeThumbSize && self.cropView.bounds.size.height -touchStart.y <kResizeThumbSize);
    
    NSLog(@"Touch Began");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.cropView];
    CGPoint previous=[[touches anyObject]previousLocationInView:self.cropView];
    
    float  deltaWidth = touchPoint.x-previous.x;
    float  deltaHeight = touchPoint.y-previous.y;
    
    if (isResizingLR) {
        self.cropView.frame = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y,touchPoint.x + deltaWidth, touchPoint.y + deltaWidth);
    }
    if (isResizingUL) {
        self.cropView.frame = CGRectMake(self.cropView.frame.origin.x + deltaWidth, self.cropView.frame.origin.y + deltaHeight, self.cropView.frame.size.width - deltaWidth, self.cropView.frame.size.height - deltaHeight);
    }
    if (isResizingUR) {
        self.cropView.frame = CGRectMake(self.cropView.frame.origin.x ,self.cropView.frame.origin.y + deltaHeight,  self.cropView.frame.size.width + deltaWidth, self.cropView.frame.size.height - deltaHeight);
    }
    if (isResizingLL) {
        self.cropView.frame = CGRectMake(self.cropView.frame.origin.x + deltaWidth ,self.cropView.frame.origin.y ,  self.cropView.frame.size.width - deltaWidth, self.cropView.frame.size.height + deltaHeight);
    }
    
    if (!isResizingUL && !isResizingLR && !isResizingUR && !isResizingLL) {
        self.cropView.center = CGPointMake(self.cropView.center.x + touchPoint.x - touchStart.x,self.cropView.center.y + touchPoint.y - touchStart.y);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Ended");
    
}

-(void)cropImage
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
    [options setValue:NULL forKey:kCIImageColorSpace];
    CIImage *beginImage = [CIImage imageWithCGImage:_displayImage.CGImage options:options];
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    [cropFilter setDefaults];
    [cropFilter setValue:beginImage forKey:@"inputImage"];
    [cropFilter setValue:[CIVector vectorWithX:self.cropView.frame.origin.x Y:self.cropView.frame.origin.y Z:self.cropView.frame.size.width W:self.cropView.frame.size.height] forKey:@"inputRectangle"];
    CIImage *outputImage = [cropFilter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    self.imageToEdit.image = newImage;
    [self.picsArray addObject:newImage];
    CGImageRelease(cgimg);
    [self performSelector:@selector(showAllImages)];

    
}

- (void)showAllImages
{
    ImagePreviewController *vc = [[ImagePreviewController alloc]init];
    [vc setArrayOfImages:self.picsArray];
    [self.navigationController pushViewController:vc animated:TRUE];
    
}



@end
