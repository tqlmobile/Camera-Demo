//
//  CameraDemoViewController.m
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/19/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "CameraDemoViewController.h"
#import "ImageEditController.h"

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
    //self.cameraUI.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
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
    //[self.picsArray addObject:originalImage];
    self.overlay.picturesTakenLabel.text = [NSString stringWithFormat:@"Pictures Taken: %i",[self.picsArray count]];
    [self displayImageforEditing:originalImage];

}

-(void)displayImageforEditing:(UIImage *)image 
{
    ImageEditController *vc = [[ImageEditController alloc]init];
    [vc setDisplayImage:image];
    [self.cameraUI pushViewController:vc animated:TRUE];
}

- (void)viewDidUnload {
    [self setOpenPhotosButton:nil];
    [super viewDidUnload];
}
@end
