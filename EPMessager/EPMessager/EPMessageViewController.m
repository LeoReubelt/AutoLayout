//
//  EPMessageViewController.m
//  EPMessager
//
//  Created by Leo Reubelt on 9/25/14.
//  Copyright (c) 2014 ENHATCH. All rights reserved.
//

#import "EPMessageViewController.h"
#import "EPMessageCell.h"
#import "NSString+EH.h"

@interface EPMessageViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextView *messageView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) NSMutableArray *tableData;

@end

#pragma mark - Lifecycle

@implementation EPMessageViewController

NSInteger const EPMessageViewHeight = 100;
NSInteger const EPSendButtonWidth = 100;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableData = @[@"cell1xxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxx xxxxxxx xxxxxxxx xxxxxxx",@"cell2",@"cell3"];
    
    [self setupTableView];
    [self setupMessageView];
    [self setupSendButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup Views

- (void)setupTableView
{
    CGRect tableViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-EPMessageViewHeight);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setupMessageView
{
    CGRect messageViewFrame = CGRectMake(0,CGRectGetHeight(self.tableView.frame),CGRectGetWidth(self.view.frame)-EPSendButtonWidth,EPMessageViewHeight);
    self.messageView = [[UITextView alloc] initWithFrame:messageViewFrame];
    self.messageView.backgroundColor = [UIColor grayColor];
    self.messageView.layer.cornerRadius = 10.0f;
    UIColor *color = [UIColor blackColor];
    self.messageView.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    self.messageView.layer.borderWidth = 3.0f;
    self.messageView.textColor = [UIColor blackColor];
    self.messageView.text = @"placeholder text";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.messageView];
    self.messageView.delegate = self;
}

- (void)setupSendButton
{
    CGRect sendButtonFrame = CGRectMake(CGRectGetWidth(self.view.frame)-EPSendButtonWidth,CGRectGetHeight(self.tableView.frame),EPSendButtonWidth,EPMessageViewHeight);
    self.sendButton = [[UIButton alloc] initWithFrame:sendButtonFrame];
    self.sendButton.layer.cornerRadius = 10.0f;
    UIColor *color = [UIColor blackColor];
    self.sendButton.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    self.sendButton.layer.borderWidth = 3.0f;
    [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.sendButton];
    [self.sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPMessageCell *cell = [[EPMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = self.tableData[indexPath.row];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"header";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *messageString = self.tableData[indexPath.row];
    return [messageString heightForTextHavingWidth:CGRectGetWidth(self.messageView.frame) font:[UIFont systemFontOfSize:16]];
}

#pragma mark - IBActions

-(IBAction)sendTapped:(id)sender
{
    NSLog(@"SEND");
}

@end
