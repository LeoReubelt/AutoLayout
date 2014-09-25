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
#import "EPMessagingManager.h"

@interface EPMessageViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITextView *messageView;
@property (weak, nonatomic) UITextField *messageField;
@property (weak, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *tableDictionary;

@end

#pragma mark - Lifecycle

@implementation EPMessageViewController

NSInteger const EPMessageViewHeight = 100;
NSInteger const EPSendButtonWidth = 100;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messages = [self dummyDataDictionary];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupTableView];
    //[self setupMessageField];
    //[self setupSendButton];
    [self setupAutoLayout];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)dummyDataDictionary
{
    NSMutableArray *dummy = [[NSMutableArray alloc] init];
    
    NSArray *messages = @[@"cell1",@"cell2",@"cell3"];
    NSArray *contacts = @[@"contact1",@"contact2",@"contact3"];
    
    for (NSInteger i = 0; i<messages.count; i++) {
        NSDictionary *message = @{messages[i]:contacts[i]};
        [dummy addObject:message];
    }
    return dummy;
}

#pragma mark - Setup Views

- (void)setupTableView
{
    CGRect tableViewFrame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-EPMessageViewHeight-CGRectGetMaxY(self.navigationController.navigationBar.frame));
    UITableView *tv = [[UITableView alloc] initWithFrame:tableViewFrame];
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    self.tableView = tv;

}

//- (void)setupMessageView
//{
//    CGRect messageViewFrame = CGRectMake(0,CGRectGetMaxY(self.tableView.frame),CGRectGetWidth(self.view.frame)-EPSendButtonWidth,EPMessageViewHeight);
//    self.messageView = [[UITextView alloc] initWithFrame:messageViewFrame];
//    self.messageView.backgroundColor = [UIColor grayColor];
//    self.messageView.layer.cornerRadius = 10.0f;
//    UIColor *color = [UIColor blackColor];
//    self.messageView.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
//    self.messageView.layer.borderWidth = 3.0f;
//    self.messageView.textColor = [UIColor blackColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    [self.view addSubview:self.messageView];
//    self.messageView.delegate = self;
//}

- (void)setupMessageField
{
    CGRect messageViewFrame = CGRectMake(0,CGRectGetMaxY(self.tableView.frame),CGRectGetWidth(self.view.frame)-EPSendButtonWidth,EPMessageViewHeight);
    
    UITextField *textField = [[UITextField alloc] initWithFrame:messageViewFrame];
    textField.backgroundColor = [UIColor grayColor];
    textField.layer.cornerRadius = 10.0f;
    UIColor *color = [UIColor blackColor];
    textField.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    textField.layer.borderWidth = 3.0f;
    textField.textColor = [UIColor blackColor];
    textField.delegate = self;
    self.messageField = textField;
    [self.view addSubview:self.messageField];
    
}

- (void)setupSendButton
{
    CGRect sendButtonFrame = CGRectMake(CGRectGetWidth(self.view.frame)-EPSendButtonWidth,CGRectGetMaxY(self.tableView.frame),EPSendButtonWidth,EPMessageViewHeight);
    UIButton *button = [[UIButton alloc] initWithFrame:sendButtonFrame];
    button.layer.cornerRadius = 10.0f;
    UIColor *color = [UIColor blackColor];
    button.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    button.layer.borderWidth = 3.0f;
    [button setTitle:@"SEND" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sendButton = button;
    [self.view addSubview:self.sendButton];
    [self.sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupAutoLayout
{
    [self.view removeConstraints:self.view.constraints];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    for (UIView *view in self.view.subviews) {
        [view removeConstraints:view.constraints];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
//    NSLayoutConstraint *tvHeight =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeHeight
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeHeight
//                                multiplier:1
//                                  constant:0.0];
//    
//    [self.view addConstraint:tvHeight];
//    
//    NSLayoutConstraint *tvWidth =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeWidth
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeWidth
//                                multiplier:1
//                                  constant:0];
//    
//    [self.view addConstraint:tvWidth];
//    
//    NSLayoutConstraint *tvTop =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeTop
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeTop
//                                multiplier:1
//                                  constant:0.0];
//    
//    [self.view addConstraint:tvTop];
//    
//    NSLayoutConstraint *tvBot =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeBottom
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeBottom
//                                multiplier:1
//                                  constant:0.0];
//    
//    [self.view addConstraint:tvBot];
//    
//    NSLayoutConstraint *tvRight =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeRight
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeRight
//                                multiplier:1
//                                  constant:0.0];
//    
//    [self.view addConstraint:tvRight];
//    
//    NSLayoutConstraint *tvLeft =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeLeft
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeLeft
//                                multiplier:1
//                                  constant:0.0];
//    
//    [self.view addConstraint:tvLeft];
//
//    NSLayoutConstraint *tvWidth =
//    [NSLayoutConstraint constraintWithItem:self.tableView
//                                 attribute:NSLayoutAttributeWidth
//                                 relatedBy:NSLayoutRelationEqual
//                                    toItem:self.view
//                                 attribute:NSLayoutAttributeWidth
//                                multiplier:1
//                                  constant:0.0];
//    
//    [self.view addConstraint:tvWidth];
//    
    NSDictionary *constraintViews = NSDictionaryOfVariableBindings(_tableView);
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_tableView]-5-|" options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:verticalConstraints];
    
    NSArray *horizontalTableViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_tableView]-5-|" options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:horizontalTableViewConstraints];
//
//    NSArray *horizontalTextViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_messageField][_sendButton]|" options:0 metrics:nil views:constraintViews];
//    [self.view addConstraints:horizontalTextViewConstraints];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EPMessageCell *cell = [[EPMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSDictionary *message = self.messages[indexPath.row];
    NSString *messageText = [message allKeys][0];
    cell.textLabel.text = messageText;
    cell.backgroundColor = [UIColor redColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.messages[indexPath.row];
    NSString *messageString = [message allKeys][0];
    return [self heightForTextHavingWidth:CGRectGetWidth(self.messageView.frame) font:[UIFont systemFontOfSize:16] withMessage:messageString];
}

#pragma mark - IBActions

-(IBAction)sendTapped:(id)sender
{
    if (self.messageView.text && ![self.messageView.text isEqualToString:@""]) {
        [EPMessagingManager sendMessage:self.messageView.text];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Must Enter Message" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - Private Methods

- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font withMessage:(NSString *)message
{
    CGFloat result = font.pointSize + 4;
    NSString *text = message;
    if (text) {
        CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
        
        CGSize size = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame)+1);
        result = MAX(size.height, result);
    }
    return result;
}

@end
