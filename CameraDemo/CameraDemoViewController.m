//
//  CameraDemoViewController.m
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/19/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "CameraDemoViewController.h"

@interface CameraDemoViewController ()

@end

@implementation CameraDemoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.cameraUI = [[UIImagePickerController alloc] init];
    self.overlay = [[CameraDemoOverlayViewController alloc]init];
    self.overlay.delegate = self;
    /*NSString *path = [[NSBundle mainBundle]pathForResource:@"rainbow" ofType:@"png"];
    NSURL *url = [NSURL fileURLWithPath:path];
    CIImage *image = [CIImage imageWithContentsOfURL:url];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    //NSLog(@"%@",[filter attributes]);
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:0.8f] forKey:@"inputIntensity"];
    
    //To use CPU Rendering
    NSDictionary *options = @{kCIContextUseSoftwareRenderer : @YES};
    
    CIContext *cpu_context = [CIContext contextWithOptions:options];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [cpu_context createCGImage:result fromRect:[result extent]];
    
    ALAssetsLibrary  *library = [ALAssetsLibrary new];
    [library writeImageToSavedPhotosAlbum:cgImage metadata:[image properties] completionBlock:^(NSURL *assetURL, NSError *error){NSLog(@"Saved");}];
    
     
     NSArray *list = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"%@",list);
    //UIImage *newImage = [UIImage imageWithCIImage:filter.outputImage];
    self.myImageView.image = [UIImage imageWithCGImage:cgImage scale:1 orientation:UIImageOrientationUp];
    //self.myImageView.image = newImage;*/

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
    [self presentModalViewController:self.cameraUI animated: YES];
}

-(void)cancel
{
    [self.picsArray removeAllObjects];
    [self dismissModalViewControllerAnimated:TRUE];
}

-(void)done
{
    [self dismissModalViewControllerAnimated:TRUE];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self];
    CameraDemoImages *imagesTableView = [[CameraDemoImages alloc]initWithImagesArray:self.picsArray];
    [nav pushViewController:imagesTableView animated:TRUE];
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
    
    [self.picsArray addObject:originalImage];
    self.overlay.picturesTakenLabel.text = [NSString stringWithFormat:@"Pictures Taken: %i",[self.picsArray count]];

    // Handle a still image capture
        
        //editedImage = (UIImage *) [info objectForKey: UIImagePickerControllerEditedImage];
        
        
        /*if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }*/
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (originalImage, nil, nil , nil);
    
    //[self dismissModalViewControllerAnimated: YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
