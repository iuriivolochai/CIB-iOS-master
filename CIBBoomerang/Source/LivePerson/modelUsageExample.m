
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//Init the model
    model = [[chatApp4Model alloc] initialize];
    model.skill = <ChatSkill>;
    model.siteid = <site id>;
    model.uri = <URI to be used e.g. https://lpwebdemo.liveperson.net>;
    
    //whther to show agent typing indications or not
    showAgentTyping = <YES/NO>;
//timer to update the chat display
    [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)3 target:self selector:@selector(updateDisplay:) userInfo:nil repeats:YES];

}

- (void)dealloc {
    [model release];
    [super dealloc];
}

//a button trigger to send a line to LP
- (void) sendLine:(id)sender{
	if (chatLine.text && [chatLine.text length] > 0){
		[model sendLine:chatLine.text];
	}
}

//a button triger to start a chat
- (void) startChat:(id)sender{
	NSInteger rc = [model startChat:@"IPhone_User"];
	
	if (rc != 201){
		if( !chatStarted){
			[model addLine:[NSString stringWithFormat:@"Unable to satrt chat with site %@", model.siteid]];
		}
		[activityIndicator stopAnimating];
	}
}

// a button trigger to stop a chat
- (void) stopChat:(id)sender{
	NSInteger rc = [model stopChat];
}


//timer's task to update the UI
-(void) updateDisplay: (NSTimer*)theTimer{
	if (chatStarted && model.chatState==chatEnded){
		//chat ended
		chatStarted = NO;
	}
	
	if (!chatStarted && model.chatState!=chatEnded){
		//chat started
		chatStarted = YES;
	}

//Display agent typing indication
	if (showAgentTyping){
		chatTitle.text= model.info.agentTyping ? @"Agent is Typing" : @"";
	}

	// Get chat lines
	NSMutableArray* linesArray = [model getLines];
	if ([linesArray count] <= chatLines){
//no new lines arrived since last view update
		return;
	}
	
	chatLines = [linesArray count];
	for (chatApp4Message* line1 in linesArray){
		//go over all the lines and update the display
		NSString* line = [self newChatLine:line1]];  // example of formatting the chat line
	}
}

- (NSString *) newChatLine: (chatApp4Message*) line{
	NSString * out;
	NSString* byClass;
	NSString* messageClass;
	
	if (line.system){
		messageClass = @"chatboxmessagecontentSystem";
		byClass = @"chatboxmessagefromSystem";
	}
	else if (line.visitor){
		messageClass = @"chatboxmessagecontentVisitor";
		byClass = @"chatboxmessagefromVisitor";
	}
	else {
		messageClass = @"chatboxmessagecontent";
		byClass = @"chatboxmessagefrom";
	}
	
	out = [NSString stringWithFormat:@"<div class='chatboxmessage'><span class='%@'>%@:&nbsp;&nbsp;</span><span class='%@'>%@</span></div>",byClass,line.by,messageClass,line.line];
	return out;
}
@end
