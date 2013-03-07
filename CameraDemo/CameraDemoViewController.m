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
    ImageEditController *vc;
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
    self.overlay.picturesTakenLabel.text = [NSString stringWithFormat:@"Pictures Taken: %i",[self.picsArray count]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissCamera)
                                                 name:@"DismissCamera"
                                               object:nil];
    
	self.cameraUI = [[UIImagePickerController alloc] init];
    self.overlay = [[CameraDemoOverlayViewController alloc]init];
    self.overlay.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(void)dismissCamera
{
    [self.picsArray removeAllObjects];
    [self dismissViewControllerAnimated:TRUE completion:nil];
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

#pragma mark- ImagePicker Delegate Methods

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [self dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSLog(@"%@",info);
   
    UIImage *originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    [self displayImageforEditing:originalImage];

}

-(void)addAnotherPage:(NSMutableArray *)imagesArray
{
    self.picsArray = imagesArray;
    [vc dismissModalViewControllerAnimated:TRUE];
    
}

-(void)finishedAddingPages:(NSMutableArray *)imagesArray
{
    self.picsArray = imagesArray;
    [vc dismissModalViewControllerAnimated:FALSE];
    ImagePreviewController *pvc = [[ImagePreviewController alloc]init];
    [pvc setArrayOfImages:self.picsArray];
    [self.cameraUI pushViewController:pvc animated:TRUE];
    
    
}

-(void)displayImageforEditing:(UIImage *)image 
{
    vc = [[ImageEditController alloc]init];
    vc.delegate = self;
    [vc setDisplayImage:image];
    [vc setImagesArray:self.picsArray];
    [self.cameraUI presentModalViewController:vc animated:TRUE];
}



- (void)viewDidUnload {
    [self setOpenPhotosButton:nil];
    [super viewDidUnload];
}
@end
