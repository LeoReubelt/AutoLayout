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

@interface EPMessageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITextView *messageView;
@property (weak, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) NSLayoutConstraint *messageViewHeight;
@property (strong, nonatomic) NSLayoutConstraint *messageBottomPosition;
@property (nonatomic) CGFloat cellTextWidth;

//dummy data
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *tableDictionary;

@end

#pragma mark - Lifecycle

@implementation EPMessageViewController

NSInteger const EPMessageViewHeight = 20.0880013;
NSInteger const EPSendButtonWidth = 100;
CGFloat const EPTextSize = 16.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cellTextWidth = CGRectGetWidth(self.view.frame)-30;
    [self setupNotifications];
    [self setupTableView];
    [self setupMessageView];
    [self setupSendButton];
    [self setupAutoLayout];
    [self.tableView reloadData];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.messages = [self dummyDataDictionary];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)dummyDataDictionary
{
    NSMutableArray *dummy = [[NSMutableArray alloc] init];
    NSArray *messages = @[@"cell1",@"cell2",@"cell3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxyx"];
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
    [tv registerClass:[EPMessageCell class] forCellReuseIdentifier:@"EMPessageCellIdentifier"];
    tv.delegate = self;
    tv.dataSource = self;
    
    [self.view addSubview:tv];
    self.tableView = tv;
}

- (void)setupMessageView
{
    CGRect messageViewFrame = CGRectMake(0,CGRectGetMaxY(self.tableView.frame),CGRectGetWidth(self.view.frame)-EPSendButtonWidth,EPMessageViewHeight);
    UITextView *textView = [[UITextView alloc] initWithFrame:messageViewFrame];
    textView.backgroundColor = [UIColor grayColor];
    textView.layer.cornerRadius = 0.0f;
    UIColor *color = [UIColor blackColor];
    textView.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    textView.layer.borderWidth = 1.0f;
    textView.textColor = [UIColor blackColor];
    textView.scrollEnabled = NO;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.font = [UIFont systemFontOfSize:EPTextSize];
    textView.textContainerInset = UIEdgeInsetsZero;

    [self.view addSubview:textView];
    self.messageView = textView;
}

- (void)setupSendButton
{
    CGRect sendButtonFrame = CGRectMake(CGRectGetWidth(self.view.frame)-EPSendButtonWidth,CGRectGetMaxY(self.tableView.frame),EPSendButtonWidth,EPMessageViewHeight);
    UIButton *button = [[UIButton alloc] initWithFrame:sendButtonFrame];
    button.layer.cornerRadius = 0.0f;
    UIColor *color = [UIColor blackColor];
    button.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    button.layer.borderWidth = 1.0f;
    [button setTitle:@"SEND" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    self.sendButton = button;
    [self.sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupAutoLayout
{
    [self.view removeConstraints:self.view.constraints];
    for (UIView *view in self.view.subviews) {
        [view removeConstraints:view.constraints];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    self.messageViewHeight =
    [NSLayoutConstraint constraintWithItem:self.messageView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:EPMessageViewHeight];
    
    [self.view addConstraint:self.messageViewHeight];
    
    NSLayoutConstraint *buttonWidth =
    [NSLayoutConstraint constraintWithItem:self.sendButton
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:EPSendButtonWidth];
    [self.view addConstraint:buttonWidth];
    
    NSLayoutConstraint *messageAndButtonHeights =
    [NSLayoutConstraint constraintWithItem:self.messageView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.sendButton
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:messageAndButtonHeights];
    
    NSLayoutConstraint *messageAndButtonBottoms =
    [NSLayoutConstraint constraintWithItem:self.messageView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.sendButton
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:messageAndButtonBottoms];
    
    self.messageBottomPosition = [NSLayoutConstraint constraintWithItem:self.messageView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:self.messageBottomPosition];

    NSDictionary *constraintViews = NSDictionaryOfVariableBindings(_tableView, _messageView, _sendButton);
    
    NSArray *messageAndButtonHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_messageView][_sendButton]|"
                                                                                  options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:messageAndButtonHorizontal];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView][_messageView]"
                                                                           options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:verticalConstraints];
    
    NSArray *horizontalTableViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                                      options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:horizontalTableViewConstraints];
}

#pragma mark - Notifications for UIKeyBoard, UITextView, and Device Orientation

- (void)setupNotifications
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceReoriented)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.messageView];
}

- (void)handleDeviceReoriented
{
    self.cellTextWidth = CGRectGetWidth(self.view.frame)-30;
    [self.tableView reloadData];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.messageBottomPosition.constant = -1*CGRectGetHeight(keyboardFrame);
    } completion:^(BOOL finished) {
    }];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.messageBottomPosition.constant = 0;
    } completion:^(BOOL finished) {
    }];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
}

- (void)handleTextViewDidChange:(NSNotification *)notification
{
    self.messageViewHeight.constant = [self heightForTextHavingWidth:self.messageView.textContainer.size.width-11
                                                                 font:[UIFont systemFontOfSize:EPTextSize]
                                                          withMessage:self.messageView.text];
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
    //EPMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EMPessageCellIdentifier" forIndexPath:indexPath];
    EPMessageCell *cell = [[EPMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMPessageCellIdentifier"];
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
    return [self heightForTextHavingWidth:self.cellTextWidth font:[UIFont systemFontOfSize:EPTextSize] withMessage:messageString];
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
    [self.messageView resignFirstResponder];
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
