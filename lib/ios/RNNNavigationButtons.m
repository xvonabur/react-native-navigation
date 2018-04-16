#import "RNNNavigationButtons.h"
#import "RNNUIBarButtonItem.h"
#import <React/RCTConvert.h>
#import "RCTHelpers.h"

@interface RNNNavigationButtons()

@property (weak, nonatomic) RNNRootViewController* viewController;
@property (strong, nonatomic) NSArray* rightButtons;
@property (strong, nonatomic) NSArray* leftButtons;

@end

@implementation RNNNavigationButtons

-(instancetype)initWithViewController:(RNNRootViewController*)viewController {
	self = [super init];
	
	self.viewController = viewController;
	
	return self;
}

-(void)applyLeftButtons:(NSArray*)leftButtons rightButtons:(NSArray*)rightButtons {
	if (leftButtons) {
		[self setButtons:leftButtons side:@"left" animated:NO];
	}
	
	if (rightButtons) {
		[self setButtons:rightButtons side:@"right" animated:NO];
	}
}

-(void)setButtons:(NSArray*)buttons side:(NSString*)side animated:(BOOL)animated {
	NSMutableArray *barButtonItems = [NSMutableArray new];
	for (RNNButtonOptions *button in buttons) {
		RNNUIBarButtonItem* barButtonItem = [self buildButton:button];
		if(barButtonItem) {
			[barButtonItems addObject:barButtonItem];
		}
	}
	
	if ([side isEqualToString:@"left"]) {
		self.leftButtons = barButtonItems;
		[self.viewController.navigationItem setLeftBarButtonItems:self.leftButtons animated:animated];
	}
	
	if ([side isEqualToString:@"right"]) {
		self.rightButtons = barButtonItems;
		[self.viewController.navigationItem setRightBarButtonItems:self.rightButtons animated:animated];
	}
}

-(RNNUIBarButtonItem*)buildButton: (RNNButtonOptions*)buttonOptions {
	if (!buttonOptions.buttonID) {
		@throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:[@"button id is not specified " stringByAppendingString:buttonOptions.title] userInfo:nil];
	}
	
	UIImage* iconImage = nil;
	if (buttonOptions.icon) {
		iconImage = [RCTConvert UIImage:buttonOptions.icon];
	}
	
	RNNUIBarButtonItem *barButtonItem;
	if (buttonOptions.componentName) {
		RCTRootView *view = (RCTRootView*)[self.viewController.creator createRootView:buttonOptions.componentName rootViewId:buttonOptions.buttonID];
		barButtonItem = [[RNNUIBarButtonItem alloc] init:buttonOptions.buttonID withCustomView:view];
	} else if (iconImage) {
		barButtonItem = [[RNNUIBarButtonItem alloc] init:buttonOptions.buttonID withIcon:iconImage];
	} else if (buttonOptions.title) {
		barButtonItem = [[RNNUIBarButtonItem alloc] init:buttonOptions.buttonID withTitle:buttonOptions.title];
	} else {
		return nil;
	}
	
	barButtonItem.target = self;
	barButtonItem.action = @selector(onButtonPress:);
	
	BOOL enabledBool = buttonOptions.enabled ? [buttonOptions.enabled boolValue] : YES;
	[barButtonItem setEnabled:enabledBool];
	
	BOOL disableIconTint = buttonOptions.disableIconTint ? [buttonOptions.disableIconTint boolValue] : NO;
	if (disableIconTint) {
		[barButtonItem setImage:[barButtonItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
	}
	
	NSMutableDictionary* textAttributes = [[NSMutableDictionary alloc] init];
	NSMutableDictionary* disabledTextAttributes = [[NSMutableDictionary alloc] init];
	
	if (buttonOptions.color) {
		[textAttributes setObject:[RCTConvert UIColor:buttonOptions.color] forKey:NSForegroundColorAttributeName];
	}
	
	if (buttonOptions.disabledColor) {
		UIColor *color = [RCTConvert UIColor:buttonOptions.disabledColor];
		[disabledTextAttributes setObject:color forKey:NSForegroundColorAttributeName];
	}
	
	NSNumber* fontSize = buttonOptions.fontSize ? buttonOptions.fontSize : @(17);
	if (buttonOptions.fontFamily) {
		[textAttributes setObject:[UIFont fontWithName:buttonOptions.fontFamily size:[buttonOptions.fontSize floatValue]] forKey:NSFontAttributeName];
	} else{
		[textAttributes setObject:[UIFont systemFontOfSize:[fontSize floatValue]] forKey:NSFontAttributeName];
	}
	
	[barButtonItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
	[barButtonItem setTitleTextAttributes:disabledTextAttributes forState:UIControlStateDisabled];
	
	if (buttonOptions.testID) {
		barButtonItem.accessibilityIdentifier = buttonOptions.testID;
	}
	
	return barButtonItem;
}

-(void)onButtonPress:(RNNUIBarButtonItem*)barButtonItem {
	[self.viewController.eventEmitter sendOnNavigationButtonPressed:self.viewController.componentId buttonId:barButtonItem.buttonId];
}

@end
