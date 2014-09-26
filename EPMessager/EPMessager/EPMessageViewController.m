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

@interface EPMessageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITextField *messageField;
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
    [self setupMessageField];
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

- (void)setupMessageField
{
    CGRect messageViewFrame = CGRectMake(0,CGRectGetMaxY(self.tableView.frame),CGRectGetWidth(self.view.frame)-EPSendButtonWidth,EPMessageViewHeight);
    UITextField *textField = [[UITextField alloc] initWithFrame:messageViewFrame];
    textField.backgroundColor = [UIColor grayColor];
    textField.layer.cornerRadius = 0.0f;
    UIColor *color = [UIColor blackColor];
    textField.layer.borderColor = CGColorCreateCopyWithAlpha(color.CGColor, 1.0f);
    textField.layer.borderWidth = 3.0f;
    textField.textColor = [UIColor blackColor];
    textField.delegate = self;
    textField.clearButtonMode = YES;
    [self.view addSubview:textField];
    self.messageField = textField;
}

- (void)setupSendButton
{
    CGRect sendButtonFrame = CGRectMake(CGRectGetWidth(self.view.frame)-EPSendButtonWidth,CGRectGetMaxY(self.tableView.frame),EPSendButtonWidth,EPMessageViewHeight);
    UIButton *button = [[UIButton alloc] initWithFrame:sendButtonFrame];
    button.layer.cornerRadius = 0.0f;
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
    for (UIView *view in self.view.subviews) {
        [view removeConstraints:view.constraints];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    self.messageFieldHeight =
    [NSLayoutConstraint constraintWithItem:self.messageField
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
    [NSLayoutConstraint constraintWithItem:self.messageField
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.sendButton
                                 attribute:NSLayoutAttributeHeight
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:messageAndButtonHeights];
    
    NSLayoutConstraint *messageAndButtonBottoms =
    [NSLayoutConstraint constraintWithItem:self.messageField
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.sendButton
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:messageAndButtonBottoms];
    
    self.messageBottomPosition = [NSLayoutConstraint constraintWithItem:self.messageField
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    
    [self.view addConstraint:self.messageBottomPosition];


    NSDictionary *constraintViews = NSDictionaryOfVariableBindings(_tableView, _messageField, _sendButton);
    
    NSArray *messageAndButtonHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_messageField][_sendButton]|" options:0 metrics:nil views:constraintViews];
    [self.view addConstraints:messageAndButtonHorizontal];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView][_messageField]" options:0 metrics:nil views:constraintViews];
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
                                             selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.messageField];
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
    self.messageFieldHeight.constant = [self heightForTextHavingWidth:CGRectGetWidth(self.messageField.frame) font:[UIFont systemFontOfSize:16] withMessage:self.messageField.text];
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
    return [self heightForTextHavingWidth:CGRectGetWidth(self.messageField.frame) font:[UIFont systemFontOfSize:16] withMessage:messageString];
}

#pragma mark - IBActions

-(IBAction)sendTapped:(id)sender
{
    if (self.messageField.text && ![self.messageField.text isEqualToString:@""]) {
        [EPMessagingManager sendMessage:self.messageField.text];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Must Enter Message" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [self.messageField resignFirstResponder];
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

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat textHeight = [self heightForTextHavingWidth:CGRectGetWidth(self.messageField.frame) font:[UIFont systemFontOfSize:16] withMessage:self.messageField.text];
}

@end
