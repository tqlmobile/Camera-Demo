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
    // Dispose of any resources that can be recreated.
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
    self.imageToEdit.image = outputImage;
    [self.imagesArray addObject:outputImage];
    [self.hud hide];
    [self performSelector:@selector(AddAnotherPage)];
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


@end
