//
//  CBChatViewController.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 6/11/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBChatViewController.h"

#import "CBUserChatMessageTableViewCell.h"
#import "CBAgentChatMessageTableViewCell.h"
#import "CBChatMessagesDateTableViewCell.h"

#import "chatApp4ModelMock.h"
#import "chatApp4Message.h"

#import "CBAppearance.h"

#define KEYBOARD_HEIGHT     216

#define AGENT_NAME      @"LivePersonAgent"
#define USER_NAME       @"IPhone_User"

@interface CBChatViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *historyTableView;
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet UITextField *messageTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;

@property (nonatomic, readonly) chatApp4ModelMock *model;

@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) NSArray *currentChatMessages;
@property (nonatomic, strong) NSMutableDictionary *datesIndeces;
@property (nonatomic, strong) NSDate *lastDate;

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)sendButtonTapped:(UIButton *)sender;

- (void)showEditingModeAnimated;
- (void)hideEditingModeAnimated:(BOOL)animated;

- (void)updateChatMessages;

- (void)configureView;

- (NSDate *)dateIfExistsWithIndexPath:(NSIndexPath *)indexPath;
- (chatApp4Message *)messageByIndexPath:(NSIndexPath *)indexPath;

- (BOOL)hasReceivedWithMessages:(NSArray *)messages fromIndex:(NSInteger)index;

@end

@implementation CBChatViewController

@synthesize model;
@synthesize datesIndeces;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hideEditingModeAnimated:NO];
    
    if ([self.model isAvailableForChat:AGENT_NAME]) {
        [self.model startChat:USER_NAME];
        
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateChatMessages) userInfo:nil repeats:YES];
    } else {
        // TODO: show chat cannot be started alert with "model.lastError"
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.model stopChat:NO];
    
    if (self.updateTimer) {
        if (self.updateTimer.isValid) {
            [self.updateTimer invalidate];
        }
        
        self.updateTimer = nil;
    }
}

#pragma mark - Actions

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonTapped:(UIButton *)sender
{
    if (self.messageTextField.text.length > 0) {
        [CBSoundUtils playSound:CBSystemSoundTypeChatMessageSent];
        
		[model sendLine:self.messageTextField.text];
		self.messageTextField.text = @"";
	}
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showEditingModeAnimated];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self hideEditingModeAnimated:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentChatMessages.count + self.datesIndeces.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self dateIfExistsWithIndexPath:indexPath];
    
    if (date) {
        static NSString *dateCellIdentifier = @"ChatMessagesDate";
        
        CBChatMessagesDateTableViewCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
        
        if (!cell) {
            cell = [[CBChatMessagesDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dateCellIdentifier];
        }
        
        [cell setDate:date];
        
        return cell;
        
    } else {
        chatApp4Message *message = [self messageByIndexPath:indexPath];
        
        if (message.visitor) {
            static NSString *userCellIdentifier = @"ChatMessageUser";
            
            CBUserChatMessageTableViewCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier:userCellIdentifier];
            
            if (!cell) {
                cell = [[CBUserChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userCellIdentifier];
            }
            
            cell.message = message.line;
            
            return cell;
            
        } else {
            static NSString *agentCellIdentifier = @"ChatMessageAgent";
            
            CBAgentChatMessageTableViewCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier:agentCellIdentifier];
            
            if (!cell) {
                cell = [[CBAgentChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:agentCellIdentifier];
            }
            
            cell.message = message.line;
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - Private

- (void)showEditingModeAnimated
{
    [UIView animateWithDuration:0.3 animations:^{
        self.historyTableView.frame = CGRectMake(
                                                 self.historyTableView.frame.origin.x,
                                                 self.historyTableView.frame.origin.y,
                                                 self.historyTableView.frame.size.width,
                                                 self.view.bounds.size.height - self.messageView.bounds.size.height - KEYBOARD_HEIGHT);
        
        self.messageView.frame = CGRectMake(
                                            self.messageView.frame.origin.x,
                                            self.view.bounds.size.height - self.messageView.bounds.size.height - KEYBOARD_HEIGHT,
                                            self.messageView.frame.size.width,
                                            self.messageView.frame.size.height);
    }];
}

- (void)hideEditingModeAnimated:(BOOL)animated
{
    CGRect historyRect = CGRectMake(
                                    self.historyTableView.frame.origin.x,
                                    self.historyTableView.frame.origin.y,
                                    self.historyTableView.frame.size.width,
                                    self.view.bounds.size.height - self.messageView.bounds.size.height);
    
    CGRect messageRect = CGRectMake(
                                    self.messageView.frame.origin.x,
                                    self.view.bounds.size.height - self.messageView.bounds.size.height,
                                    self.messageView.frame.size.width,
                                    self.messageView.frame.size.height);
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.historyTableView.frame = historyRect;
            self.messageView.frame = messageRect;
        }];
    } else {
        self.historyTableView.frame = historyRect;
        self.messageView.frame = messageRect;
    }
}

- (void)configureView
{
    UIImage *sendImage = [UIImage imageNamed:@"Bar-Button.png"];
    [self.sendButton setBackgroundImage:[sendImage resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)] forState:UIControlStateNormal];
    
    [CBAppearance customizeViewController:self withTitle:NSLocalizedString(@"Chat", nil)
                     leftBarBarButtonType:CBAppearanceButtonTypeNone
                       rightBarButtonType:CBAppearanceButtonTypeNone];
}

- (void)updateChatMessages
{
    if (([self.model getLines].count > 0) && (!self.currentChatMessages || (self.currentChatMessages.count < [self.model getLines].count))) {
        
        NSDate *currentDate = [NSDate date];
        
        if (!self.lastDate || ([currentDate timeIntervalSinceDate:self.lastDate] > 5)) {
            [self.datesIndeces setObject:(self.lastDate) ? (self.lastDate) : currentDate
								  forKey:[NSNumber numberWithInteger:(self.currentChatMessages.count + self.datesIndeces.count)]];
        }
        
        self.lastDate = currentDate;
        NSArray *tempArray = [NSArray arrayWithArray:[self.model getLines]];
        
        // check if any messages were received and play sound
        if ([self hasReceivedWithMessages:tempArray fromIndex:self.currentChatMessages.count]) {
            [CBSoundUtils playSound:CBSystemSoundTypeChatMessageReceived];
        }
        
        self.currentChatMessages = tempArray;
        
        BOOL needToScrollDown = self.historyTableView.contentSize.height - self.historyTableView.frame.size.height - self.historyTableView.contentOffset.y < 10;
        
        [self.historyTableView reloadData];
        
        CGFloat yOffset = self.historyTableView.contentSize.height - self.historyTableView.frame.size.height;
        
        if (needToScrollDown && yOffset > 0) {
            [self.historyTableView setContentOffset:CGPointMake(0, yOffset) animated:YES];
        }
    }
}

- (NSMutableDictionary *)datesIndeces
{
    if (!datesIndeces) {
        datesIndeces = [[NSMutableDictionary alloc] init];
    }
    
    return datesIndeces;
}

- (NSDate *)dateIfExistsWithIndexPath:(NSIndexPath *)indexPath
{
    for (NSNumber *index in [self.datesIndeces allKeys]) {
        if ([index integerValue] == indexPath.row) {
            return self.datesIndeces[index];
        }
    }
    
    return NO;
}

- (chatApp4Message *)messageByIndexPath:(NSIndexPath *)indexPath {
    NSInteger finalIndex = indexPath.row;
    
    for (NSNumber *index in [self.datesIndeces allKeys]) {
        if ([indexPath row] > [index integerValue]) {
            finalIndex--;
        }
    }
    
    return self.currentChatMessages[finalIndex];
}

- (BOOL)hasReceivedWithMessages:(NSArray *)messages fromIndex:(NSInteger)index
{
    if (messages.count <= index) {
        return NO;
    }
    
    for (NSInteger i = index; i < messages.count; ++i) {
        chatApp4Message *message = messages[i];
        
        if (!message.visitor) {
            return YES;
        }
    }
    
    return NO;
}

- (chatApp4ModelMock *)model
{
    if (!model) {
        model = [[chatApp4ModelMock alloc] init];       // change method name to 'initialize'
        model.skill = @"";
        model.siteid = @"";
        model.uri = @"https://api.liveperson.net";
        model.translate = NO;
    }
    
    return model;
}

@end
