//
//  SecurityCodeInputController.m
//  AppSales
//
//  Created by Nicolas Gomollon on 12/1/15.
//
//

#import "SecurityCodeInputController.h"

@implementation SecurityCodeInputController

- (id)init {
	return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		// Initialization code
		securityCodeField = [[UITextField alloc] initWithFrame:CGRectZero];
		securityCodeField.delegate = self;
		securityCodeField.keyboardAppearance = UIKeyboardAppearanceDark;
		securityCodeField.keyboardType = UIKeyboardTypeNumberPad;
		[self.view addSubview:securityCodeField];
		[securityCodeField becomeFirstResponder];
		
		digitView = [[UIView alloc] initWithFrame:CGRectZero];
		digitView.backgroundColor = [UIColor clearColor];
		digitView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:digitView];
		
		digit1 = self.digitLabel;
		[digitView addSubview:digit1];
		
		digit2 = self.digitLabel;
		[digitView addSubview:digit2];
		
		digit3 = self.digitLabel;
		[digitView addSubview:digit3];
		
		digit4 = self.digitLabel;
		[digitView addSubview:digit4];
		
		digits = [[NSMutableArray alloc] init];
		[digits addObject:digit1];
		[digits addObject:digit2];
		[digits addObject:digit3];
		[digits addObject:digit4];
		
		
		/* Horizontal Layout */
		
		CGFloat digitViewWidth = 280.0f;
		CGFloat digitWidth = 50.0f;
		CGFloat digitPadding = (digitViewWidth - (digitWidth * (CGFloat)digits.count)) / (CGFloat)(digits.count - 1);
		
		[digitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[digit1(w)]-p-[digit2(w)]-p-[digit3(w)]-p-[digit4(w)]|"
																		  options:0
																		  metrics:@{@"w": @(digitWidth), @"p": @(digitPadding)}
																			views:@{@"digit1": digit1, @"digit2": digit2, @"digit3": digit3, @"digit4": digit4}]];
		
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:digitView
															  attribute:NSLayoutAttributeWidth
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1.0f
															   constant:digitViewWidth]];
		
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:digitView
															  attribute:NSLayoutAttributeCenterX
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.view
															  attribute:NSLayoutAttributeCenterX
															 multiplier:1.0f
															   constant:0.0f]];
		
		
		/* Vertical Layout */
		
		[digitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[digit1]|"
																		  options:0
																		  metrics:nil
																			views:@{@"digit1": digit1}]];
		
		[digitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[digit2]|"
																		  options:0
																		  metrics:nil
																			views:@{@"digit2": digit2}]];
		
		[digitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[digit3]|"
																		  options:0
																		  metrics:nil
																			views:@{@"digit3": digit3}]];
		
		[digitView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[digit4]|"
																		  options:0
																		  metrics:nil
																			views:@{@"digit4": digit4}]];
		
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:digitView
															  attribute:NSLayoutAttributeHeight
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1.0f
															   constant:60.0f]];
		
		digitViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:digitView
																  attribute:NSLayoutAttributeCenterY
																  relatedBy:NSLayoutRelationEqual
																	 toItem:self.view
																  attribute:NSLayoutAttributeCenterY
																 multiplier:1.0f
																   constant:0.0f];
		[self.view addConstraint:digitViewCenterYConstraint];
	}
	return self;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGFloat topOffset = self.topLayoutGuide.length;
	digitViewCenterYConstraint.constant = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) ? -((topOffset + 216.0f) / 2.0f) : -((topOffset + 162.0f) / 2.0f);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Do any additional setup after loading the view.
	self.title = NSLocalizedString(@"Enter Verification Code", nil);
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit", nil) style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)show {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (viewController.presentedViewController != nil) {
		viewController = viewController.presentedViewController;
	}
	[viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)submit {
	[securityCodeField resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:^{
		if ([self.delegate respondsToSelector:@selector(securityCodeInputSubmitted:)]) {
			[self.delegate securityCodeInputSubmitted:securityCodeField.text];
		}
	}];
}

- (void)dismiss {
	[securityCodeField resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:^{
		if ([self.delegate respondsToSelector:@selector(securityCodeInputCanceled)]) {
			[self.delegate securityCodeInputCanceled];
		}
	}];
}

- (UILabel *)digitLabel {
	UILabel *digitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	digitLabel.backgroundColor = [UIColor whiteColor];
	digitLabel.clipsToBounds = YES;
	digitLabel.font = [UIFont boldSystemFontOfSize:24.0f];
	digitLabel.textAlignment = NSTextAlignmentCenter;
	digitLabel.textColor = [UIColor blackColor];
	digitLabel.translatesAutoresizingMaskIntoConstraints = NO;
	digitLabel.layer.borderColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:147.0f/255.0f alpha:1.0f].CGColor;
	digitLabel.layer.borderWidth = 1.0f;
	digitLabel.layer.cornerRadius = 4.0f;
	return digitLabel;
}

- (BOOL)isValidDigit:(NSString *)string {
	if (string.length != 1) { return NO; }
	unichar c = [string characterAtIndex:0];
	return ('0' <= c) && (c <= '9');
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if ((range.length > 1) || (newText.length > 4)) { return NO; }
	if ((string.length == 0) || [self isValidDigit:string]) {
		self.navigationItem.rightBarButtonItem.enabled = (newText.length == 4);
		for (NSInteger i = 0; i < digits.count; i++) {
			UILabel *digit = digits[i];
			if (i < newText.length) {
				unichar c = [newText characterAtIndex:i];
				digit.text = [NSString stringWithFormat:@"%c", c];
			} else {
				digit.text = nil;
			}
		}
		return YES;
	}
	return NO;
}

@end
