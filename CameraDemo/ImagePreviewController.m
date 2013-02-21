//
//  ImagePreviewController.m
//  CameraDemo
//
//  Created by TQL on 2/20/13.
//  Copyright (c) 2013 Total Quality Logistics. All rights reserved.
//

#import "ImagePreviewController.h"
#import "ImageEditController.h"
#import "ProcessDocsViewController.h"

@interface ImagePreviewController ()

@end

@implementation ImagePreviewController

@synthesize arrayOfImages = _arrayOfImages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *)arrayOfImages
{
    if (_arrayOfImages == nil)
    {
        _arrayOfImages = [[NSMutableArray alloc]init];
    }
    return _arrayOfImages;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.imagesTableView reloadData];
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithTitle:@"Process" style:UIBarButtonItemStyleDone target:self action:@selector(processDocs)];
    self.navigationItem.rightBarButtonItem = done;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Current Documents";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)processDocs
{
    ProcessDocsViewController *vc = [[ProcessDocsViewController alloc]init];
    [vc setAllDocsArray:self.arrayOfImages];
    [self.navigationController pushViewController:vc animated:TRUE];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.arrayOfImages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Document %i", indexPath.row];
    cell.imageView.image = [self.arrayOfImages objectAtIndex:indexPath.row];
    // Configure the cell...
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    ImageEditController *iec = [ImageEditController new];
    [iec setDisplayImage:[self.arrayOfImages objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:iec animated:TRUE];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
