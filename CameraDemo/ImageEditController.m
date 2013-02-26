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
    NSLog(@"Crop View Dimensions: X:%f Y:%f W:%f H:%f",self.cropView.frame.origin.x,self.cropView.frame.origin.y,self.cropView.frame.size.width,self.cropView.frame.size.height);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches Ended");
    
}

-(void)cropImage
{
    
    NSLog(@"Original Image size: W:%f H:%f",self.displayImage.size.width, self.displayImage.size.height);
    CGSize size;
    size.width = 320;
    size.height = 416;
    self.displayImage = [self imageWithImage:self.displayImage scaledToSize:size];
    NSLog(@"Scaled Image size: W:%f H:%f",self.displayImage.size.width, self.displayImage.size.height);
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
    [options setValue:NULL forKey:kCIImageColorSpace];
    CIImage *beginImage = [CIImage imageWithCGImage:_displayImage.CGImage options:options];
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    [cropFilter setDefaults];
    [cropFilter setValue:beginImage forKey:@"inputImage"];
    //CGRect rect = CGRectMake(24, 72 ,271,334);
    CGRect rect = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y ,self.cropView.frame.size.width,self.cropView.frame.size.height);
    [cropFilter setValue:[CIVector vectorWithCGRect:rect] forKey:@"inputRectangle"];
    CIImage *outputImage = [cropFilter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    self.displayImage = newImage;
    CGImageRelease(cgimg);
    [self showAllImages];
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    /*NSLog(@"Crop View Dimensions: X:%f Y:%f W:%f H:%f",self.cropView.frame.origin.x,self.cropView.frame.origin.y,self.cropView.frame.size.width,self.cropView.frame.size.height);
    //CGRect rect = CGRectMake(self.cropView.frame.origin.x, self.cropView.frame.origin.y ,self.cropView.frame.size.width,self.cropView.frame.size.height);
    CGRect rect = CGRectMake(24, 72 ,271,334);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.displayImage CGImage], rect);
    self.displayImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);*/
    [self performSelector:@selector(showAllImages)];
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)showAllImages
{
    ImagePreviewController *vc = [[ImagePreviewController alloc]init];
    [vc.arrayOfImages addObject:self.displayImage];
    [self.navigationController pushViewController:vc animated:TRUE];
    
}



@end
