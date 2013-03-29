//
//  CameraDemoViewController.m
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/19/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "CameraDemoViewController.h"
#import "ProcessDocsViewController.h"

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
    
    /*UIImage *stubImage = [UIImage imageNamed:@"example.jpg"];
    CGSize size;
    size.width = stubImage.size.width/3;
    size.height = stubImage.size.height/3;
    stubImage = [self imageWithImage:stubImage scaledToSize:size];
    NSLog(@"StubImage size: w%f x h%f",stubImage.size.width,stubImage.size.height);
    
    NSMutableArray *stubArray = [NSMutableArray arrayWithObjects:stubImage,stubImage,stubImage,stubImage,stubImage,stubImage,stubImage, nil];
    
    ProcessDocsViewController *vcx = [[ProcessDocsViewController alloc]init];
    [vcx setAllDocsArray:stubArray];
    [self.navigationController pushViewController:vcx animated:TRUE];*/
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
    NSLog(@"Original Size: Width:%f Height:%f",originalImage.size.width,originalImage.size.height);
    //CGSize size;
    //size.width = 936;
    //size.height = 1592;
    //originalImage = [self imageWithImage:originalImage scaledToSize:size];
    [self displayImageforEditing:originalImage];
    originalImage = nil;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
