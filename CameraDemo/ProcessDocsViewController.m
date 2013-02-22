//
//  ProcessDocsViewController.m
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/21/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//
#define kPadding 20
#define kPageWidth 850
#define kPageHeight 1100
#define kImageWidth 810
#define kImageHeight 1060

#import "ProcessDocsViewController.h"

@interface ProcessDocsViewController ()
{
    CGSize _pageSize;
    int pageNumber;
    CIContext *context;
    
}
@end

@implementation ProcessDocsViewController

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
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendPDF)];
    self.navigationItem.rightBarButtonItem = sendButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    context = [CIContext contextWithOptions:nil];
    [self performSelector:@selector(enhanceImages)];
    [self setupPDFDocumentNamed:@"ExamplePDF" Width:kPageWidth Height:kPageHeight];
    pageNumber = 0;
    for (UIImage *image in _allDocsArray)
    {
        [self beginPDFPage];
        pageNumber++;
    }
    [self finishPDF];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enhanceImages
{
    
    for (int i = 0; i < [self.allDocsArray count]; i++)
    {
        UIImage *inputImage = [self.allDocsArray objectAtIndex:i];
        inputImage = [self rotate:inputImage andOrientation:UIImageOrientationUp];
        CIImage *beginImage = [CIImage imageWithCGImage:inputImage.CGImage];
        /*CIFilter *filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust" keysAndValues:kCIInputImageKey,beginImage,nil];
        [filter setValue:[NSNumber numberWithFloat: 1.0f]
                  forKey:@"inputHighlightAmount"];
        [filter setValue:[NSNumber numberWithFloat: -1.0f]
                  forKey:@"inputShadowAmount"];*/
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setDefaults];
        [filter setValue: beginImage forKey: @"inputImage"];
        [filter setValue: [NSNumber numberWithFloat:0.5f]
                                   forKey:@"inputBrightness"];
        [filter setValue: [NSNumber numberWithFloat:2.0f]
                                   forKey:@"inputContrast"];
        CIImage *outputImage = [filter outputImage];
        CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage *newImage = [UIImage imageWithCGImage:cgimg];
        [self.allDocsArray replaceObjectAtIndex:i withObject:newImage];
        CGImageRelease(cgimg);
    }
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

#pragma mark- Begin PDF Conversion

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height
{
    _pageSize = CGSizeMake(width, height);
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
}

- (void)beginPDFPage {
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, _pageSize.width, _pageSize.height), nil);
    
    [self addImage:[self.allDocsArray objectAtIndex:pageNumber]
                                  atPoint:CGPointMake(kPadding, kPadding)];
}


- (void)finishPDF {
    UIGraphicsEndPDFContext();
}

#pragma mark- Add a PDF Page
- (CGRect)addImage:(UIImage*)image atPoint:(CGPoint)point
{
    if (image.size.width > kImageWidth && image.size.height > kImageHeight)
    {
        CGSize newSize;
        newSize.width = kImageWidth;
        newSize.height = kImageHeight;
        image = [self resizeImage:image newSize:newSize];
    }
    UIImage *compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
    CGRect imageFrame = CGRectMake(point.x, point.y, kImageWidth, kImageHeight);
    [compressedImage drawInRect:imageFrame];
    return imageFrame;
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark- Send PDF to File Server
-(void)sendPDF
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"ExamplePDF.pdf"];
    NSData *data = [NSData dataWithContentsOfFile:pdfPath];
    
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if ([mailClass canSendMail])
    {
        MFMailComposeViewController *compose = [[MFMailComposeViewController alloc]init];
        compose.mailComposeDelegate = self;
        [compose addAttachmentData:data mimeType:@"pdf" fileName:@"Example PDF"];
        [compose setSubject:@"New Example Document"];
        [compose setToRecipients:[NSArray arrayWithObject:@"ctritt@tql.com"]];
        [self presentModalViewController:compose animated:YES];
    }
    
    
    /*NSString *path = [[NSBundle mainBundle]pathForResource:@"SoapMessage" ofType:@"plist"];
    NSDictionary *soapDict = [[NSDictionary alloc]initWithContentsOfFile:path];
   
    NSString *dataString = [data base64EncodedString];
    
    
    NSURL *url = [NSURL URLWithString:@"https://testmobileapps.tql.com/carriers/carriersuite/securemethods.asmx"];
    NSString *soapMessage = [soapDict valueForKey:@"DocumentImaging_UploadDocument_v1_0"];
    soapMessage = [NSString stringWithFormat:soapMessage,@"ExampleFile.pdf",dataString];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapMessage length]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"SOAPAction" value:@"http://mobileapps.tql.com/Carriers/CarrierDashboard/DocumentImaging_UploadDocument_v1_0"];
    [request appendPostData:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    [request addRequestHeader:@"Content-Length" value:msgLength];
    [request addBasicAuthenticationHeaderWithUsername:@"dbcarrier" andPassword:@"dbcarrier"];
    [request setDelegate:self];
    [request startAsynchronous];*/
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@",responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}

#pragma mark- MailComposerViewController Delegate Method
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
