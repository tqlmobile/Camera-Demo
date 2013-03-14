//
//  ProcessDocsViewController.m
//  CameraDemo
//
//  Created by Total Quality Logistics on 2/21/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//
#define kPadding 20
#define kPageWidth 612
#define kPageHeight 792


typedef void (*FilterCallback)(UInt8 *pixelBuf, UInt32 offset, void *context);

#import "ProcessDocsViewController.h"
#import "ImageHelper.h"
#import "GPUImage.h"


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
    for (UIImage *image in self.allDocsArray)
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
    
    @autoreleasepool {
        int count = [self.allDocsArray count];
        for (int i = 0; i < count; i++)
        {
            NSLog(@"i = %i", i);
            UIImage *inputImage = [self.allDocsArray objectAtIndex:i];
            GPUImageAdaptiveThresholdFilter *adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc]init];
            inputImage = [adaptiveThresholdFilter imageByFilteringImage:inputImage];
            adaptiveThresholdFilter = nil;
            [self.allDocsArray addObject:inputImage];
            inputImage = nil;
            NSLog(@"Finished");
            sleep(3);
        }

    }
}

/*cv::Mat inputMat = [self cvMatFromUIImage:inputImage];
 cv::Mat greyScale;
 cv::cvtColor(inputMat, greyScale, CV_BGR2GRAY);
 //cv::Mat dst;
 //cv::equalizeHist(greyScale, dst);
 cv::Mat newMat;
 cv::adaptiveThreshold(greyScale, newMat, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 75, 20);*/
//UIImage *finalImage = [self UIImageFromCVMat:newMat];

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



#pragma mark- Begin PDF Conversion

- (void)setupPDFDocumentNamed:(NSString*)name Width:(float)width Height:(float)height
{
    _pageSize = CGSizeMake(width, height);
    
    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", name];
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
    NSLog(@"Page Number: %i",pageNumber);
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
    CGRect imageFrame = CGRectMake(point.x, point.y, kPageWidth, kPageHeight);
    [compressedImage drawInRect:imageFrame];
    return imageFrame;
}

#pragma mark- Send PDF to File Server
-(void)sendPDF
{
    
    NSData *data = [NSData dataWithContentsOfFile:pdfPath];
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
    
    //Remove files from Library directory
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFile = [documentsDirectory stringByAppendingPathComponent:@"SamplePDF.pdf"];
    BOOL fileExists = [self fileExistsAtAbsolutePath:pdfFile];
    NSLog(@"File Exists %@", fileExists ? @"True" : @"False");*/
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

-(BOOL)fileExistsAtAbsolutePath:(NSString*)filename {
    BOOL isDirectory;
    BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDirectory];
    
    return fileExistsAtPath && !isDirectory;
}
@end
