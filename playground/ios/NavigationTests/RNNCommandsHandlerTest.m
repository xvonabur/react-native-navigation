#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <ReactNativeNavigation/RNNCommandsHandler.h>
#import <ReactNativeNavigation/RNNNavigationOptions.h>
#import "RNNTestRootViewCreator.h"
#import <ReactNativeNavigation/RNNComponentViewController.h>
#import <ReactNativeNavigation/RNNStackController.h>
#import <ReactNativeNavigation/RNNErrorHandler.h>
#import <OCMock/OCMock.h>
#import "RNNLayoutManager.h"
#import "RNNBottomTabsController.h"
#import "BottomTabsAttachModeFactory.h"

@interface MockUIApplication : NSObject

-(UIWindow *)keyWindow;

@end

@implementation MockUIApplication

- (UIWindow *)keyWindow {
	return [UIWindow new];
}

@end

@interface MockUINavigationController : RNNStackController
@property (nonatomic, strong) NSArray* willReturnVCs;
@end

@implementation MockUINavigationController

-(NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	return self.willReturnVCs;
}

-(NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
	return self.willReturnVCs;
}

@end

@interface RNNCommandsHandlerTest : XCTestCase

@property (nonatomic, strong) RNNCommandsHandler* uut;
@property (nonatomic, strong) id modalManager;
@property (nonatomic, strong) RNNComponentViewController* vc1;
@property (nonatomic, strong) RNNComponentViewController* vc2;
@property (nonatomic, strong) RNNComponentViewController* vc3;
@property (nonatomic, strong) MockUINavigationController* nvc;
@property (nonatomic, strong) id mainWindow;
@property (nonatomic, strong) id sharedApplication;
@property (nonatomic, strong) id controllerFactory;
@property (nonatomic, strong) id overlayManager;
@property (nonatomic, strong) id eventEmmiter;
@property (nonatomic, strong) id creator;

@end

@implementation RNNCommandsHandlerTest

- (void)setUp {
	[super setUp];
	self.sharedApplication = [OCMockObject mockForClass:[UIApplication class]];
	self.creator = [OCMockObject partialMockForObject:[RNNTestRootViewCreator new]];
	self.mainWindow = [OCMockObject partialMockForObject:[UIWindow new]];
	self.eventEmmiter = [OCMockObject partialMockForObject:[RNNEventEmitter new]];
	self.overlayManager = [OCMockObject partialMockForObject:[RNNOverlayManager new]];
	self.modalManager = [OCMockObject partialMockForObject:[RNNModalManager new]];
	self.controllerFactory = [OCMockObject partialMockForObject:[[RNNControllerFactory alloc] initWithRootViewCreator:nil eventEmitter:self.eventEmmiter store:nil componentRegistry:nil andBridge:nil bottomTabsAttachModeFactory:[BottomTabsAttachModeFactory new]]];
	self.uut = [[RNNCommandsHandler alloc] initWithControllerFactory:self.controllerFactory eventEmitter:self.eventEmmiter modalManager:self.modalManager overlayManager:self.overlayManager mainWindow:_mainWindow];
	self.vc1 = [self generateComponentWithComponentId:@"1"];
	self.vc2 = [self generateComponentWithComponentId:@"2"];
	self.vc3 = [self generateComponentWithComponentId:@"3"];
	_nvc = [[MockUINavigationController alloc] init];
	[_nvc setViewControllers:@[self.vc1, self.vc2, self.vc3]];
	OCMStub([self.sharedApplication keyWindow]).andReturn(self.mainWindow);
}

- (RNNComponentViewController *)generateComponentWithComponentId:(NSString *)componentId {
	RNNLayoutInfo* layoutInfo = [[RNNLayoutInfo alloc] init];
	layoutInfo.componentId = componentId;
	return [[RNNComponentViewController alloc] initWithLayoutInfo:layoutInfo rootViewCreator:_creator eventEmitter:nil presenter:[RNNComponentPresenter new] options:[[RNNNavigationOptions alloc] initWithDict:@{}] defaultOptions:nil];
}

- (void)testAssertReadyForEachMethodThrowsExceptions {
	NSArray* methods = [self getPublicMethodNamesForObject:self.uut];
	[self.uut setReadyToReceiveCommands:false];
	for (NSString* methodName in methods) {
		SEL s = NSSelectorFromString(methodName);
		IMP imp = [self.uut methodForSelector:s];
		void (*func)(id, SEL, id, id, id, id, id) = (void *)imp;
		XCTAssertThrowsSpecificNamed(func(self.uut,s, nil, nil, nil, nil, nil), NSException, @"BridgeNotLoadedError");
	}
}

- (NSArray*)getPublicMethodNamesForObject:(NSObject*)obj {
	NSMutableArray* skipMethods = [NSMutableArray new];
	
	[skipMethods addObject:@"initWithControllerFactory:eventEmitter:modalManager:overlayManager:mainWindow:"];
	[skipMethods addObject:@"assertReady"];
	[skipMethods addObject:@"setReadyToReceiveCommands:"];
	[skipMethods addObject:@"readyToReceiveCommands"];
	[skipMethods addObject:@".cxx_destruct"];
	[skipMethods addObject:@"dismissedModal:"];
	[skipMethods addObject:@"attemptedToDismissModal:"];
	[skipMethods addObject:@"dismissedMultipleModals:"];
	
	NSMutableArray* result = [NSMutableArray new];
	
	// count and names:
	int i=0;
	unsigned int mc = 0;
	Method * mlist = class_copyMethodList(object_getClass(obj), &mc);
	
	for(i=0; i<mc; i++) {
		NSString *methodName = [NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))];
		
		// filter skippedMethods
		if (methodName && ![skipMethods containsObject:methodName]) {
			[result addObject:methodName];
		}
	}
	
	return result;
}

-(void)testDynamicStylesMergeWithStaticStyles {
	RNNNavigationOptions* initialOptions = [[RNNNavigationOptions alloc] initWithDict:@{}];
	initialOptions.topBar.title.text = [[Text alloc] initWithValue:@"the title"];
	RNNLayoutInfo* layoutInfo = [RNNLayoutInfo new];
	RNNTestRootViewCreator* creator = [[RNNTestRootViewCreator alloc] init];
	
	RNNComponentPresenter* presenter = [[RNNComponentPresenter alloc] initWithComponentRegistry:nil defaultOptions:nil];
	RNNComponentViewController* vc = [[RNNComponentViewController alloc] initWithLayoutInfo:layoutInfo rootViewCreator:creator eventEmitter:nil presenter:presenter options:initialOptions defaultOptions:nil];
	
	RNNStackController* nav = [[RNNStackController alloc] initWithLayoutInfo:nil creator:creator options:[[RNNNavigationOptions alloc] initEmptyOptions] defaultOptions:nil presenter:[[RNNStackPresenter alloc] init] eventEmitter:nil childViewControllers:@[vc]];
	
	[vc viewWillAppear:false];
	XCTAssertTrue([vc.navigationItem.title isEqual:@"the title"]);
	
	[self.uut setReadyToReceiveCommands:true];
	
	NSDictionary* dictFromJs = @{@"topBar": @{@"background" : @{@"color" : @(0xFFFF0000)}}};
	UIColor* expectedColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
	
	[self.uut mergeOptions:@"componentId" options:dictFromJs completion:^{
		XCTAssertTrue([vc.navigationItem.title isEqual:@"the title"]);
		XCTAssertTrue([nav.navigationBar.barTintColor isEqual:expectedColor]);
	}];
}

- (void)testMergeOptions_shouldOverrideOptions {
	RNNNavigationOptions* initialOptions = [[RNNNavigationOptions alloc] initWithDict:@{}];
	initialOptions.topBar.title.text = [[Text alloc] initWithValue:@"the title"];
	
	RNNComponentPresenter* presenter = [[RNNComponentPresenter alloc] initWithComponentRegistry:nil defaultOptions:nil];
	RNNComponentViewController* vc = [[RNNComponentViewController alloc] initWithLayoutInfo:nil rootViewCreator:[[RNNTestRootViewCreator alloc] init] eventEmitter:nil presenter:presenter options:initialOptions defaultOptions:nil];
	
	__unused RNNStackController* nav = [[RNNStackController alloc] initWithRootViewController:vc];
	[vc viewWillAppear:false];
	XCTAssertTrue([vc.navigationItem.title isEqual:@"the title"]);
	
	[self.uut setReadyToReceiveCommands:true];
	
	NSDictionary* dictFromJs = @{@"topBar": @{@"title" : @{@"text" : @"new title"}}};
	
	[self.uut mergeOptions:@"componentId" options:dictFromJs completion:^{
		XCTAssertTrue([vc.navigationItem.title isEqual:@"new title"]);
	}];
}

- (void)testShowOverlay_createLayout {
	[self.uut setReadyToReceiveCommands:true];
	OCMStub([self.overlayManager showOverlayWindow:[OCMArg any]]);
	NSDictionary* layout = @{};
	
	[[self.controllerFactory expect] createLayout:layout];
	[self.uut showOverlay:layout commandId:@"" completion:^{}];
	[self.controllerFactory verify];
}

- (void)testShowOverlay_saveToStore {
	[self.uut setReadyToReceiveCommands:true];
	OCMStub([self.overlayManager showOverlayWindow:[OCMArg any]]);
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]);
	
	[[self.controllerFactory expect] createLayout:[OCMArg any]];
	[self.uut showOverlay:@{} commandId:@"" completion:^{}];
	[self.overlayManager verify];
}

- (void)testShowOverlay_withCreatedLayout {
	[self.uut setReadyToReceiveCommands:true];
	UIViewController* layoutVC = [self generateComponentWithComponentId:nil];
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(layoutVC);
	
	[[self.overlayManager expect] showOverlayWindow:[OCMArg any]];
	[self.uut showOverlay:@{} commandId:@"" completion:^{}];
	[self.overlayManager verify];
}

- (void)testShowOverlay_invokeNavigationCommandEventWithLayout {
	[self.uut setReadyToReceiveCommands:true];
	OCMStub([self.overlayManager showOverlayWindow:[OCMArg any]]);
	id mockedVC = [OCMockObject partialMockForObject:self.vc1];
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(mockedVC);
	
	NSDictionary* layout = @{};
	
	[[self.eventEmmiter expect] sendOnNavigationCommandCompletion:@"showOverlay" commandId:[OCMArg any] params:[OCMArg any]];
	[self.uut showOverlay:layout commandId:@"" completion:^{}];
	[self.eventEmmiter verify];
}

- (void)testDismissOverlay_findComponentFromLayoutManager {
	[self.uut setReadyToReceiveCommands:true];
	NSString* componentId = @"componentId";
	id classMock = OCMClassMock([RNNLayoutManager class]);
	[[classMock expect] findComponentForId:componentId];
	[self.uut dismissOverlay:componentId commandId:@"" completion:^{} rejection:^(NSString *code, NSString *message, NSError *error) {}];
	[classMock verify];
}

- (void)testDismissOverlay_dismissReturnedViewController {
	[self.uut setReadyToReceiveCommands:true];
	NSString* componentId = @"componentId";
	UIViewController* returnedView = [UIViewController new];
	
	id classMock = OCMClassMock([RNNLayoutManager class]);
	OCMStub(ClassMethod([classMock findComponentForId:componentId])).andReturn(returnedView);
	
	[[self.overlayManager expect] dismissOverlay:returnedView];
	[self.uut dismissOverlay:componentId commandId:@"" completion:^{} rejection:^(NSString *code, NSString *message, NSError *error) {}];
	[self.overlayManager verify];
}

- (void)testDismissOverlay_handleErrorIfNoOverlayExists {
	[self.uut setReadyToReceiveCommands:true];
	NSString* componentId = @"componentId";
	id errorHandlerMockClass = [OCMockObject mockForClass:[RNNErrorHandler class]];
	
	[[errorHandlerMockClass expect] reject:[OCMArg any] withErrorCode:1010 errorDescription:[OCMArg any]];
	[self.uut dismissOverlay:componentId commandId:@"" completion:[OCMArg any] rejection:[OCMArg any]];
	[errorHandlerMockClass verify];
}

- (void)testDismissOverlay_invokeNavigationCommandEvent {
	[self.uut setReadyToReceiveCommands:true];
	NSString* componentId = @"componentId";
	
	id classMock = OCMClassMock([RNNLayoutManager class]);
	OCMStub(ClassMethod([classMock findComponentForId:componentId])).andReturn([UIViewController new]);
	
	[[self.eventEmmiter expect] sendOnNavigationCommandCompletion:@"dismissOverlay" commandId:[OCMArg any] params:[OCMArg any]];
	[self.uut dismissOverlay:componentId commandId:@"" completion:^{
		
	} rejection:^(NSString *code, NSString *message, NSError *error) {}];
	
	[self.eventEmmiter verify];
}

- (void)testSetRoot_setRootViewControllerOnMainWindow {
	[self.uut setReadyToReceiveCommands:true];
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(self.vc1);
	
	[[self.mainWindow expect] setRootViewController:self.vc1];
	[self.uut setRoot:@{} commandId:@"" completion:^{}];
	[self.mainWindow verify];
}

- (void)testSetStackRoot_resetStackWithSingleComponent {
	OCMStub([self.controllerFactory createChildrenLayout:[OCMArg any]]).andReturn(@[self.vc2]);
	[self.uut setReadyToReceiveCommands:true];
	id classMock = OCMClassMock([RNNLayoutManager class]);
	OCMStub(ClassMethod([classMock findComponentForId:@"vc1"])).andReturn(_nvc);
	self.vc2.options.animations.setStackRoot.enable = [[Bool alloc] initWithBOOL:NO];
	
	[self.uut setStackRoot:@"vc1" commandId:@"" children:nil completion:^{

	} rejection:^(NSString *code, NSString *message, NSError *error) {
		
	}];
	
	XCTAssertEqual(_nvc.viewControllers.firstObject, self.vc2);
	XCTAssertEqual(_nvc.viewControllers.count, 1);
}

- (void)testSetStackRoot_setMultipleChildren {
	NSArray* newViewControllers = @[_vc1, _vc3];
	id classMock = OCMClassMock([RNNLayoutManager class]);
	OCMStub(ClassMethod([classMock findComponentForId:@"vc1"])).andReturn(_nvc);
	OCMStub([self.controllerFactory createChildrenLayout:[OCMArg any]]).andReturn(newViewControllers);
	[self.uut setReadyToReceiveCommands:true];
	
	_vc3.options.animations.setStackRoot.enable = [[Bool alloc] initWithBOOL:NO];
	[self.uut setStackRoot:@"vc1" commandId:@"" children:nil completion:^{
	
	} rejection:^(NSString *code, NSString *message, NSError *error) {
		
	}];
	XCTAssertTrue([_nvc.viewControllers isEqual:newViewControllers]);
}

- (void)testSetStackRoot_callRenderTreeAndWaitOnce {
	id vc1Mock = [OCMockObject partialMockForObject:_vc1];
	id vc2Mock = [OCMockObject partialMockForObject:_vc2];
	NSArray* newViewControllers = @[vc1Mock, vc2Mock];
	
	OCMStub([self.controllerFactory createChildrenLayout:[OCMArg any]]).andReturn(newViewControllers);
	[self.uut setReadyToReceiveCommands:true];
	[self.uut setStackRoot:@"vc1" commandId:@"" children:nil completion:^{
		
	} rejection:^(NSString *code, NSString *message, NSError *error) {
		
	}];
	
	[[vc1Mock expect] render];
	[[vc2Mock expect] render];
}

- (void)testSetStackRoot_waitForRender {
	_vc2.options.animations.setStackRoot.waitForRender = [[Bool alloc] initWithBOOL:YES];
	id vc1Mock = OCMPartialMock(_vc1);
	id vc2Mock = OCMPartialMock(_vc2);
	
	NSArray* newViewControllers = @[vc1Mock, vc2Mock];
	
	OCMStub([self.controllerFactory createChildrenLayout:[OCMArg any]]).andReturn(newViewControllers);
	
	[self.uut setReadyToReceiveCommands:true];
	[self.uut setStackRoot:@"vc1" commandId:@"" children:nil completion:^{
		
	} rejection:^(NSString *code, NSString *message, NSError *error) {
		
	}];
	
	[[vc1Mock expect] render];
	[[vc2Mock expect] render];
}

- (void)testSetRoot_waitForRenderTrue {
	[self.uut setReadyToReceiveCommands:true];
	self.vc1.options = [[RNNNavigationOptions alloc] initEmptyOptions];
	self.vc1.options.animations.setRoot.waitForRender = [[Bool alloc] initWithBOOL:YES];
	
	id mockedVC = [OCMockObject partialMockForObject:self.vc1];
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(mockedVC);
	
	[[mockedVC expect] render];
	[self.uut setRoot:@{} commandId:@"" completion:^{}];
	[mockedVC verify];
}

- (void)testSetRoot_waitForRenderFalse {
	[self.uut setReadyToReceiveCommands:true];
	self.vc1.options = [[RNNNavigationOptions alloc] initEmptyOptions];
	self.vc1.options.animations.setRoot.waitForRender = [[Bool alloc] initWithBOOL:NO];
	
	id mockedVC = [OCMockObject partialMockForObject:self.vc1];
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(mockedVC);
	
	[[mockedVC expect] render];
	[self.uut setRoot:@{} commandId:@"" completion:^{}];
	[mockedVC verify];
}

- (void)testSetRoot_withBottomTabsAttachModeTogether {
	[self.uut setReadyToReceiveCommands:true];
	RNNNavigationOptions* options = [[RNNNavigationOptions alloc] initEmptyOptions];
	options.bottomTabs.tabsAttachMode = [[BottomTabsAttachMode alloc] initWithValue:@"together"];

	BottomTabsBaseAttacher* attacher = [[[BottomTabsAttachModeFactory alloc] initWithDefaultOptions:nil] fromOptions:options];
	RNNBottomTabsController* tabBarController = [[RNNBottomTabsController alloc] initWithLayoutInfo:nil creator:nil options:options defaultOptions:[[RNNNavigationOptions alloc] initEmptyOptions] presenter:[RNNBasePresenter new] bottomTabPresenter:nil dotIndicatorPresenter:nil eventEmitter:_eventEmmiter childViewControllers:@[_vc1, _vc2] bottomTabsAttacher:attacher];

	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(tabBarController);
	
	[self.uut setRoot:@{} commandId:@"" completion:^{}];
	XCTAssertTrue(_vc1.isViewLoaded);
	XCTAssertTrue(_vc2.isViewLoaded);
	XCTAssertEqual(_vc1.view.tag, 1);
	XCTAssertEqual(_vc2.view.tag, 2);
}

- (void)testSetRoot_withBottomTabsAttachModeOnSwitchToTab {
	[self.uut setReadyToReceiveCommands:true];
	RNNNavigationOptions* options = [[RNNNavigationOptions alloc] initEmptyOptions];
	options.bottomTabs.tabsAttachMode = [[BottomTabsAttachMode alloc] initWithValue:@"onSwitchToTab"];
	options.animations.setRoot.waitForRender = [[Bool alloc] initWithBOOL:YES];
	
	BottomTabsBaseAttacher* attacher = [[[BottomTabsAttachModeFactory alloc] initWithDefaultOptions:nil] fromOptions:options];
	RNNBottomTabsController* tabBarController = [[RNNBottomTabsController alloc] initWithLayoutInfo:nil creator:nil options:options defaultOptions:[[RNNNavigationOptions alloc] initEmptyOptions] presenter:[RNNBasePresenter new] bottomTabPresenter:nil dotIndicatorPresenter:nil eventEmitter:_eventEmmiter childViewControllers:@[_vc1, _vc2] bottomTabsAttacher:attacher];

	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(tabBarController);
	
	[self.uut setRoot:@{} commandId:@"" completion:^{}];
	XCTAssertTrue(_vc1.isViewLoaded);
	XCTAssertFalse(_vc2.isViewLoaded);
	[tabBarController setSelectedIndex:1];
	XCTAssertTrue(_vc2.isViewLoaded);
}

- (void)testSetRoot_withBottomTabsAttachModeAfterInitialTab {
	[self.uut setReadyToReceiveCommands:true];
	RNNNavigationOptions* options = [[RNNNavigationOptions alloc] initEmptyOptions];
	options.bottomTabs.tabsAttachMode = [[BottomTabsAttachMode alloc] initWithValue:@"afterInitialTab"];
	options.animations.setRoot.waitForRender = [[Bool alloc] initWithBOOL:YES];

	BottomTabsBaseAttacher* attacher = [[[BottomTabsAttachModeFactory alloc] initWithDefaultOptions:nil] fromOptions:options];
	RNNBottomTabsController* tabBarController = [[RNNBottomTabsController alloc] initWithLayoutInfo:nil creator:nil options:options defaultOptions:[[RNNNavigationOptions alloc] initEmptyOptions] presenter:[RNNBasePresenter new] bottomTabPresenter:nil dotIndicatorPresenter:nil eventEmitter:_eventEmmiter childViewControllers:@[_vc1, _vc2] bottomTabsAttacher:attacher];

	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(tabBarController);

	[self.uut setRoot:@{} commandId:@"" completion:^{
		XCTAssertFalse(self->_vc2.isViewLoaded);
	}];

	XCTAssertTrue(_vc1.isViewLoaded);
	XCTAssertTrue(_vc2.isViewLoaded);
}

- (void)testShowModal_shouldShowAnimated {
	[self.uut setReadyToReceiveCommands:true];
	self.vc1.options = [[RNNNavigationOptions alloc] initEmptyOptions];
	self.vc1.options.animations.showModal.enable = [[Bool alloc] initWithBOOL:YES];
	
	id mockedVC = [OCMockObject partialMockForObject:self.vc1];
	OCMStub([self.controllerFactory createLayout:[OCMArg any]]).andReturn(mockedVC);
	
	[[self.modalManager expect] showModal:mockedVC animated:YES completion:[OCMArg any]];
	[self.uut showModal:@{} commandId:@"showModal" completion:^(NSString *componentId) {
		
	}];
	[self.modalManager verify];
}


@end
