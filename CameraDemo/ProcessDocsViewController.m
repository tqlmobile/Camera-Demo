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

typedef void (*FilterCallback)(UInt8 *pixelBuf, UInt32 offset, void *context);

#import "ProcessDocsViewController.h"
#import "ImageHelper.h"


@interface ProcessDocsViewController ()
{
    CGSize _pageSize;
    int pageNumber;
    CIContext *context;
    NSString *pdfPath;
    NSString *pdfFileName;
    
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
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject: [NSNull null] forKey: kCIContextWorkingColorSpace];
    context = [CIContext contextWithOptions:options];
    [self performSelector:@selector(enhanceImages)];
    [self setupPDFDocumentNamed:@"SamplePDF" Width:kPageWidth Height:kPageHeight];
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
    CGSize newImageSize;
    newImageSize.width = 810;
    newImageSize.height = 1060;
    for (int i = 0; i < [self.allDocsArray count]; i++)
    {
        UIImage *inputImage = [self.allDocsArray objectAtIndex:i];
        inputImage = [self imageWithImage:inputImage scaledToSize:newImageSize];
        //inputImage = [self convertToBW:inputImage];
        //inputImage = [self convertImageToGreyScale:inputImage];

        
        CIImage *beginImage = [CIImage imageWithCGImage:inputImage.CGImage options:nil];
        
        /*CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, beginImage, @"inputEV", [NSNumber numberWithFloat:0.7], nil].outputImage;*/
        CIImage *output = [CIFilter filterWithName:@"CIMinimumComponent" keysAndValues:kCIInputImageKey, beginImage, nil].outputImage;
        NSArray *adjustments = [beginImage autoAdjustmentFiltersWithOptions:nil];
        NSLog(@"%@",adjustments);
        for (CIFilter *filter in adjustments){
            [filter setValue:output forKey:kCIInputImageKey];
            output = filter.outputImage;
        }
        CGImageRef cgimg = [context createCGImage:output fromRect:[output extent]];
        UIImage *newImage = [UIImage imageWithCGImage:cgimg];
        [self.allDocsArray replaceObjectAtIndex:i withObject:newImage];
        CGImageRelease(cgimg);
        NSLog(@"Finished");
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)convertImageToGreyScale:(UIImage *)image
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(contextRef, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(contextRef);
    CFRelease(imageRef);
    
    return newImage;
}




#pragma mark- Begin PDF Conversion

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height
{
    _pageSize = CGSizeMake(width, height);
    
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
    //NSString *newPDFName = [self createPDFName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];
    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
}

-(NSString *)createPDFName
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    pdfFileName = [NSString stringWithFormat:@"SamplePDF %@",formattedDateString];
    pdfFileName = [pdfFileName stringByReplacingOccurrencesOfString:@"," withString:@""];
    pdfFileName = [pdfFileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    pdfFileName = [pdfFileName stringByReplacingOccurrencesOfString:@":" withString:@"t"];
    pdfFileName = [pdfFileName stringByAppendingFormat:@".pdf"];
    NSLog(@"%@",pdfFileName);
    return pdfFileName;
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
    UIImage *compressedImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
    CGRect imageFrame = CGRectMake(point.x, point.y, kImageWidth, kImageHeight);
    [compressedImage drawInRect:imageFrame];
    return imageFrame;
}

#pragma mark- Send PDF to File Server
-(void)sendPDF
{
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"ExamplePDF.pdf"];
    NSData *data = [NSData dataWithContentsOfFile:pdfPath];
    
    
    /*Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if ([mailClass canSendMail])
    {
        MFMailComposeViewController *compose = [[MFMailComposeViewController alloc]init];
        compose.mailComposeDelegate = self;
        [compose addAttachmentData:data mimeType:@"pdf" fileName:pdfFileName];
        [compose setSubject:@"New Example Document"];
        [compose setToRecipients:[NSArray arrayWithObject:@"ctritt@tql.com"]];
        [self presentModalViewController:compose animated:YES];
    }*/
    
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"SoapMessage" ofType:@"plist"];
    NSDictionary *soapDict = [[NSDictionary alloc]initWithContentsOfFile:path];
   
    NSString *dataString = [data base64EncodedString];
    
    
    NSURL *url = [NSURL URLWithString:@"https://testmobileapps.tql.com/carriers/carriersuite/securemethods.asmx"];
    NSString *soapMessage = [soapDict valueForKey:@"DocumentImaging_UploadDocument_v1_0"];
    soapMessage = [NSString stringWithFormat:soapMessage,[self createPDFName],dataString];
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
    [request startAsynchronous];
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
