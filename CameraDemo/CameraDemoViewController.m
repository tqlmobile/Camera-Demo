//
//  CameraDemoViewController.m
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/19/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "CameraDemoViewController.h"

@interface CameraDemoViewController ()
{
    CIContext *context;
}
@end

@implementation CameraDemoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Camera Demo";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.cameraUI = [[UIImagePickerController alloc] init];
    self.overlay = [[CameraDemoOverlayViewController alloc]init];
    self.overlay.delegate = self;
    NSArray *filters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    for (NSString *filterName in filters)
    {
        CIFilter *cifltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@",filterName);
        NSLog(@"%@",[cifltr attributes]);
    }
}

-(ImagePreviewController *)imagePreview
{
    if (_imagePreview == nil)
    {
        _imagePreview = [[ImagePreviewController alloc]init];
    }
    return _imagePreview;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)picsArray
{
    if (_picsArray == nil)
    {
        _picsArray = [[NSMutableArray alloc]init];
    }
    return _picsArray;
}

-(void)takePicture
{
    [self.cameraUI takePicture];
}

- (IBAction)openCamera:(id)sender
{
    self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                           UIImagePickerControllerSourceTypeCamera];
    
    self.cameraUI.allowsEditing = YES;
    self.cameraUI.showsCameraControls = NO;
    self.cameraUI.delegate = self;
    self.cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    self.cameraUI.cameraOverlayView = self.overlay.view;
    self.overlay.picturesTakenLabel.text = [NSString stringWithFormat:@"Pictures Taken: %i",[self.picsArray count]];
    [self presentModalViewController:self.cameraUI animated: YES];
}

- (IBAction)openPhotos:(id)sender
{
    if (self.picsArray == nil)
    {
        [self.imagePreview setArrayOfImages:self.picsArray];
    }
    [self.imagePreview setArrayOfImages:self.picsArray];
    [self.navigationController pushViewController:self.imagePreview animated:TRUE];
}

-(void)cancel
{
    [self.picsArray removeAllObjects];
    [self dismissModalViewControllerAnimated:TRUE];
}

-(void)done
{
    [self.cameraUI dismissModalViewControllerAnimated:TRUE];
}

#pragma mark- ImagePicker Delegate Methods

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [self dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSLog(@"%@",info);
   
    UIImage *originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    originalImage = [self rotate:originalImage andOrientation:UIImageOrientationUp];
    NSLog(@"Original Image Size: %f by %f", originalImage.size.width, originalImage.size.height);
    /*context = [CIContext contextWithOptions:nil];
    CIImage *beginImage = [CIImage imageWithCGImage:originalImage.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [filter setValue:beginImage forKey:@"inputImage"];
    [filter setValue:@1 forKey:@"inputAspectRatio"];
    [filter setValue:@0.4 forKey:@"inputScale"];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];*/
    CGSize newImageSize;
    newImageSize.width = 810;
    newImageSize.height = 1060;
    originalImage = [self imageWithImage:originalImage scaledToSize:newImageSize];
     NSLog(@"New Image Size: %f by %f", originalImage.size.width, originalImage.size.height);
    [self.picsArray addObject:originalImage];
    self.overlay.picturesTakenLabel.text = [NSString stringWithFormat:@"Pictures Taken: %i",[self.picsArray count]];

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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidUnload {
    [self setOpenPhotosButton:nil];
    [super viewDidUnload];
}
@end
