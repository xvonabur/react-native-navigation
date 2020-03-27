#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <ReactNativeNavigation/TopBarAppearancePresenter.h>
#import "UIViewController+RNNOptions.h"
#import <ReactNativeNavigation/RNNStackController.h>
#import <ReactNativeNavigation/RNNComponentViewController.h>
#import "RNNComponentViewController+Utils.h"

@interface TopBarAppearancePresenterTest : XCTestCase

@end

@implementation TopBarAppearancePresenterTest {
	TopBarAppearancePresenter* _uut;
	RNNStackController* _stack;
	RNNComponentViewController* _componentViewController;
}

- (void)setUp {
    [super setUp];
	_componentViewController = [RNNComponentViewController createWithComponentId:@"componentId"];
	_stack = [[RNNStackController alloc] initWithLayoutInfo:nil creator:nil options:[[RNNNavigationOptions alloc] initEmptyOptions] defaultOptions:[[RNNNavigationOptions alloc] initEmptyOptions] presenter:_uut eventEmitter:nil childViewControllers:@[_componentViewController]];
	_uut = [[TopBarAppearancePresenter alloc] initWithNavigationController:_stack];
}

- (void)testMergeOptions_shouldMergeWithDefault {
	RNNNavigationOptions* mergeOptions = [[RNNNavigationOptions alloc] initEmptyOptions];
	RNNNavigationOptions* defaultOptions = [[RNNNavigationOptions alloc] initEmptyOptions];
	defaultOptions.topBar.title.color = [Color withColor:UIColor.redColor];
	
	mergeOptions.topBar.title.fontSize = [Number withValue:@(21)];
	RNNNavigationOptions* withDefault = [mergeOptions withDefault:defaultOptions];
	[_uut mergeOptions:mergeOptions.topBar withDefault:withDefault.topBar];
	XCTAssertEqual(_stack.childViewControllers.lastObject.navigationItem.standardAppearance.titleTextAttributes[NSForegroundColorAttributeName], UIColor.redColor);
	UIFont* font = _stack.childViewControllers.lastObject.navigationItem.standardAppearance.titleTextAttributes[NSFontAttributeName];
	XCTAssertEqual(font.pointSize, 21);
}

- (void)testApplyOptions_shouldSetBackButtonTestID {
	RNNNavigationOptions* options = [[RNNNavigationOptions alloc] initEmptyOptions];
	options.topBar.backButton.testID = [Text withValue:@"TestID"];
	
	[_uut applyOptions:options.topBar];
	XCTAssertTrue([_componentViewController.navigationItem.backBarButtonItem.accessibilityIdentifier isEqualToString:@"TestID"]);
}



@end
