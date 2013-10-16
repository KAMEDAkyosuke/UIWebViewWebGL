//
//  RootViewController.m
//  UIWebViewWebGL
//
//  Created by organlounge on 2013/10/16.
//  Copyright (c) 2013年 Nathan de Vries. All rights reserved.
//

#import "RootViewController.h"

#import "Bookmark.h"
#import "Datastore.h"
#import "WebGLViewController.h"

typedef NS_ENUM(uint8_t, Section){
    kSectionBookmark = 0,
    kSectionSize,
};

static const NSString * const kSectionName[] = {
    @"Bookmark",
};

typedef NS_ENUM(uint8_t, AlertTag){
    kAlertTagInputBookmark = 0,
};

static void input_bookmark_alert_clicked_button_at_index(UIViewController*, UIAlertView*, NSInteger);
static void (*alert_clicked_button_at_index[])(UIViewController*, UIAlertView*, NSInteger) = {
    input_bookmark_alert_clicked_button_at_index,
};


@interface RootViewController () < UIAlertViewDelegate >

@property (nonatomic, strong) NSMutableArray *bookmark;

@end

@implementation RootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.bookmark = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem =
    [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                target:self
                                                action:@selector(editBookmark:)];
    
    self.navigationItem.rightBarButtonItem =
        [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                    target:self
                                                    action:@selector(addBookmark:)];
    self.bookmark = [NSMutableArray arrayWithArray:[[Datastore sharedDatastore] bookmarks]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionSize;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (NSString*)kSectionName[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case kSectionBookmark:
            rows = self.bookmark.count;
            break;
        default:
            assert(false);
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case kSectionBookmark:
        {
            Bookmark *bookmark = self.bookmark[indexPath.row];
            cell.textLabel.text = bookmark.url;
        }
            break;
        default:
            assert(false);
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kSectionBookmark:
            switch (editingStyle) {
                case UITableViewCellEditingStyleDelete:
                    [[Datastore sharedDatastore] deletBookmark:[self.bookmark objectAtIndex:indexPath.row]];
                    [self.bookmark removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                default:
                    assert(false);
                    break;
            }
            break;
        default:
            assert(false);
            break;
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kSectionBookmark:
        {
            Bookmark *bookmark = self.bookmark[indexPath.row];
            WebGLViewController *next = [WebGLViewController.alloc init];
            next.url = bookmark.url;
            [self.navigationController pushViewController:next animated:YES];
        }
            break;
        default:
            assert(false);
            break;
    }
}

- (void)editBookmark:(id)sender
{
    [self.tableView setEditing:![self.tableView isEditing]
                      animated:YES];
}

- (void)addBookmark:(id)sender
{
    UIAlertView *alertView = [UIAlertView.alloc initWithTitle:@"add bookmark"
                                                      message:@"input url"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Add", nil];
    alertView.tag = kAlertTagInputBookmark;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alert_clicked_button_at_index[alertView.tag](self, alertView, buttonIndex);
}

@end

static void input_bookmark_alert_clicked_button_at_index(UIViewController *viewController,
                                                         UIAlertView *alertView,
                                                         NSInteger buttonIndex)
{
    RootViewController *vc = (RootViewController*) viewController;
    switch (buttonIndex) {
        case 0:    /* cancel */
            break;
        case 1:    /* ok */
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *url = textField.text;
            if(url != nil && url.length > 0){
                Bookmark *bookmark = [Bookmark.alloc init];
                bookmark.url = url;
                [[Datastore sharedDatastore] insertOrReplaceBookmark:bookmark];
                
                [vc.bookmark insertObject:bookmark atIndex:0];
                [vc.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionBookmark]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
            break;
        default:
            assert(false);
            break;
    }
}

