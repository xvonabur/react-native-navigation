#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "RNNBottomTabsPresenter.h"
#import "UITabBarController+RNNOptions.h"
#import "RNNBottomTabsController.h"

@interface RNNBottomTabsPresenterTest : XCTestCase

@property(nonatomic, strong) RNNBottomTabsPresenter *uut;
@property(nonatomic, strong) RNNNavigationOptions *options;
@property(nonatomic, strong) id boundViewController;

@end

@implementation RNNBottomTabsPresenterTest

- (void)setUp {
    [super setUp];
    self.uut = [OCMockObject partialMockForObject:[RNNBottomTabsPresenter new]];
    self.boundViewController = [OCMockObject partialMockForObject:[RNNBottomTabsController new]];
    [self.uut bindViewController:self.boundViewController];
    self.options = [[RNNNavigationOptions alloc] initEmptyOptions];
}

- (void)testApplyOptions_shouldSetDefaultEmptyOptions {
    RNNNavigationOptions *emptyOptions = [[RNNNavigationOptions alloc] initEmptyOptions];
    [[self.boundViewController expect] setTabBarTestID:nil];
	[[(id)self.uut expect] applyBackgroundColor:nil translucent:NO];
    [[self.boundViewController expect] setTabBarHideShadow:NO];
    [[self.boundViewController expect] setTabBarStyle:UIBarStyleDefault];
    [self.uut applyOptions:emptyOptions];
    [self.boundViewController verify];
}

- (void)testApplyOptions_shouldApplyOptions {
    RNNNavigationOptions *initialOptions = [[RNNNavigationOptions alloc] initEmptyOptions];
    initialOptions.bottomTabs.testID = [[Text alloc] initWithValue:@"testID"];
    initialOptions.bottomTabs.backgroundColor = [[Color alloc] initWithValue:[UIColor redColor]];
    initialOptions.bottomTabs.translucent = [[Bool alloc] initWithValue:@(0)];
    initialOptions.bottomTabs.hideShadow = [[Bool alloc] initWithValue:@(1)];
    initialOptions.bottomTabs.visible = [[Bool alloc] initWithValue:@(0)];
    initialOptions.bottomTabs.barStyle = [[Text alloc] initWithValue:@"black"];

    [[self.boundViewController expect] setTabBarTestID:@"testID"];
    [[(id)self.uut expect] applyBackgroundColor:nil translucent:[UIColor redColor]];
    [[self.boundViewController expect] setTabBarHideShadow:YES];
    [[self.boundViewController expect] setTabBarStyle:UIBarStyleBlack];

    [self.uut applyOptions:initialOptions];
    [self.boundViewController verify];
}

- (void)testApplyOptionsOnInit_alwaysShow_shouldNotCenterTabImages {
	RNNNavigationOptions *initialOptions = [[RNNNavigationOptions alloc] initEmptyOptions];
	initialOptions.bottomTabs.titleDisplayMode = [[Text alloc] initWithValue:@"alwaysShow"];
	[[self.boundViewController reject] centerTabItems];
	[self.uut applyOptionsOnInit:initialOptions];
	[self.boundViewController verify];
}

- (void)testApplyOptions_shouldApplyOptionsOnInit_alwaysHide_shouldCenterTabImages {
	RNNNavigationOptions *initialOptions = [[RNNNavigationOptions alloc] initEmptyOptions];
	initialOptions.bottomTabs.titleDisplayMode = [[Text alloc] initWithValue:@"alwaysHide"];
	[[self.boundViewController expect] centerTabItems];
	[self.uut applyOptionsOnInit:initialOptions];
	[self.boundViewController verify];
}

- (void)testBackgroundColor_validColor {
	UIColor* inputColor = [RCTConvert UIColor:@(0xFFFF0000)];
	self.options.layout.backgroundColor = [[Color alloc] initWithValue:inputColor];
	[self.uut applyOptions:self.options];
	UIColor* expectedColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
	XCTAssertTrue([((UIViewController *)self.boundViewController).view.backgroundColor isEqual:expectedColor]);
}

- (void)testTabBarBackgroundColor {
	UIColor* tabBarBackgroundColor = [UIColor redColor];

	[self.uut setTabBarBackgroundColor:tabBarBackgroundColor];
	XCTAssertTrue([((UIViewController *)self.uut).tabBarController.tabBar.barTintColor isEqual:tabBarBackgroundColor]);
}

@end
