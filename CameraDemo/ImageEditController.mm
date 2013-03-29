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
#import "ImageHelper.h"
#import "GPUImage.h"  

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
    //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStyleBordered target:self action:@selector(beginCropping)];
    //self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = TRUE;
    
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
    
    self.hud = [[ATMHud alloc]initWithDelegate:self];
    self.hud.center = self.view.center;
    [self.view addSubview:self.hud.view];
    
    context = [CIContext contextWithOptions:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.displayImage = nil;
    self.cropView = nil;

}

- (void)viewDidUnload
{
    [self setImageToEdit:nil];
    [super viewDidUnload];
}

-(NSMutableArray *)imagesArray
{
    if (_imagesArray == nil)
    {
        _imagesArray = [[NSMutableArray alloc]init];
    }
    return _imagesArray;
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

- (IBAction)cropImage:(id)sender
{
    [self.hud setCaption:@"Cropping..."];
    [self.hud setActivity:TRUE];
    [self.hud show];
    [self performSelectorInBackground:@selector(cropImage) withObject:nil];
}

- (IBAction)retakeButton:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}
- (IBAction)closeButton:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
}

-(void)cropImage
{
    double scaleX = self.displayImage.size.width/self.imageToEdit.frame.size.width;
    double scaleY = self.displayImage.size.height/(self.imageToEdit.frame.size.height);
    double scaleWidth = self.cropView.frame.size.width/self.imageToEdit.frame.size.width;
    double scaleHeight = self.cropView.frame.size.height/self.imageToEdit.frame.size.height;
    CGRect rect = CGRectMake((self.cropView.frame.origin.x*scaleX), (self.cropView.frame.origin.y*scaleY),(self.displayImage.size.width*scaleWidth),(self.displayImage.size.height*scaleHeight));
    UIImage *image = [self rotate:self.displayImage andOrientation:UIImageOrientationUp];
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
    NSLog(@"Image Size: %f x %f",outputImage.size.width,outputImage.size.height);
    self.imageToEdit.image = outputImage;
    
    [self enhanceImage:outputImage];
    
    //[self.imagesArray addObject:outputImage];
    [self.hud hide];
    CGImageRelease(imageRef);
    [self performSelector:@selector(AddAnotherPage)];
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.5);
    CGContextRef contextz = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(contextz, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(contextz, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(contextz, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(contextz);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*) rotate:(UIImage*) src andOrientation:(UIImageOrientation)orientation
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef contextt = (UIGraphicsGetCurrentContext());
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (contextt, 90/180*M_PI) ;
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (contextt, -90/180*M_PI);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (contextt, 90/180*M_PI);
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

-(void)AddAnotherPage
{
    if (!self.isEditing)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Add another document"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Finished"
                                      otherButtonTitles:@"Add Another Page", nil];
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Edit Image"
                                      delegate:self
                                      cancelButtonTitle:nil
                                      destructiveButtonTitle:@"Finished"
                                      otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
    

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 2:
            [self.imagesArray removeObjectAtIndex:([self.imagesArray count])-1];
            self.imageToEdit.image = self.displayImage;
            break;
        case 0:
            [self.delegate finishedAddingPages:self.imagesArray];
            break;
        case 1:
            [self.delegate addAnotherPage:self.imagesArray];
        default:
            break;
    }
}

#pragma mark - Enhance Image

-(void)enhanceImage:(UIImage *)image
{
    dispatch_queue_t myCustomQueue;
    myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
    
    dispatch_async(myCustomQueue, ^{
        UIImage *inputImage = image;
        GPUImageAdaptiveThresholdFilter *adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc]init];
        [adaptiveThresholdFilter setBlurSize:3];
        [adaptiveThresholdFilter setShouldSmoothlyScaleOutput:TRUE];
        inputImage = [adaptiveThresholdFilter imageByFilteringImage:inputImage];
        adaptiveThresholdFilter = nil;
        /*cv::Mat inputMat = [self cvMatFromUIImage:inputImage];
        cv::Mat greyScale;
        cv::cvtColor(inputMat, greyScale, CV_BGR2GRAY);
        //cv::Mat dst;
        //cv::equalizeHist(greyScale, dst);
        cv::Mat newMat;
        cv::adaptiveThreshold(greyScale, newMat, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 75, 10);
        UIImage *finalImage = [self UIImageFromCVMat:newMat];*/
        //[self.allDocsArray replaceObjectAtIndex:i withObject:finalImage];
        [self.imagesArray addObject:inputImage];
        NSLog(@"Finished");
    });
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
