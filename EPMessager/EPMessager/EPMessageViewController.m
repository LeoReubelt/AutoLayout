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
//@property (weak, nonatomic) UITextField *messageField;
@property (weak, nonatomic) UITextView *messageView;
@property (weak, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *tableDictionary;
@property (strong, nonatomic) NSLayoutConstraint *messageFieldHeight;
@property (strong, nonatomic) NSLayoutConstraint *messageBottomPosition;

@end

#pragma mark - Lifecycle

@implementation EPMessageViewController

NSInteger const EPMessageViewHeight = 20.0880013;
NSInteger const EPSendButtonWidth = 100;
CGFloat const EPTextSize = 16.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.messages = [self dummyDataDictionary];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupKeyBoardNotification];
    [self setupTableView];
    [self setupMessageView];
    [self setupSendButton];
    [self setupAutoLayout];
    [self.tableView reloadData];
    self.automaticallyAdjustsScrollViewInsets = YES;
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
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    self.tableView = tv;

}

//- (void)setupMessageField
//{
//    CGRect messageViewFrame = CGRectMake(0,CGRectGetMaxY(self.tableView.frame),CGRectGetWidth(self.view.frame)-EPSendButtonWidth,EPMessageViewHeight);
//    UITextField *textField = [[UITextField alloc] initWithFrame:messageViewFrame];
//    textField.backgroundColor = [UIColor grayColor];
//    textField.layer.cornerRadius = 0.0f;
//    UIColor *color = [UIColor blackColor];
//    textField.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
//    textField.layer.borderWidth = 3.0f;
//    textField.textColor = [UIColor blackColor];
//    textField.delegate = self;
//    textField.clearButtonMode = YES;
//    [self.view addSubview:textField];
//    self.messageField = textField;
//}

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
    self.sendButton = button;
    [self.view addSubview:self.sendButton];
    [self.sendButton addTarget:self action:@selector(sendTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupAutoLayout
{
    [self.view removeConstraints:self.view.constraints];
    for (UIView *view in self.view.subviews) {
        [view removeConstraints:view.constraints];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    self.messageFieldHeight =
    [NSLayoutConstraint constraintWithItem:self.messageView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:EPMessageViewHeight];
    
    [self.view addConstraint:self.messageFieldHeight];
    
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
    
    NSArray *messageAndButtonHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_messageView][_sendButton]|" options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:messageAndButtonHorizontal];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView][_messageView]" options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:verticalConstraints];
    
    NSArray *horizontalTableViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:horizontalTableViewConstraints];
}

#pragma mark - KeyBoard Reaction

- (void)setupKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:) name:UITextViewTextDidChangeNotification object:self.messageView];
}

- (void)keyboardWillShow:(NSNotification *)notification
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

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.messageBottomPosition.constant = 0;
    } completion:^(BOOL finished) {
    }];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
//    NSDictionary *attributes = @{@"font":[UIFont systemFontOfSize:EPTextSize]};
//    CGSize stringSize = [self.messageView.text sizeWithAttributes:nil];
//    NSInteger numberOfLines = ceilf(stringSize.width/self.messageView.textContainer.size.width);
//    self.messageFieldHeight.constant = numberOfLines*(stringSize.height+10);
    
    self.messageFieldHeight.constant = [self heightForTextHavingWidth:self.messageView.textContainer.size.width-11 font:[UIFont systemFontOfSize:EPTextSize] withMessage:self.messageView.text];
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
    return [self heightForTextHavingWidth:CGRectGetWidth(self.view.frame) font:[UIFont systemFontOfSize:EPTextSize] withMessage:messageString];
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
