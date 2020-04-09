#import "CommandsHandlerCreator.h"
#import "RNNTestRootViewCreator.h"
#import <ReactNativeNavigation/RNNEventEmitter.h>
#import <ReactNativeNavigation/RNNOverlayManager.h>
#import <ReactNativeNavigation/RNNModalManager.h>
#import <ReactNativeNavigation/RNNControllerFactory.h>

@implementation CommandsHandlerCreator

+ (RNNCommandsHandler *)createWithWindow:(UIWindow *)window {
	RNNTestRootViewCreator* creator = [RNNTestRootViewCreator new];
	RNNEventEmitter* eventEmmiter = [RNNEventEmitter new];
	RNNOverlayManager* overlayManager = [RNNOverlayManager new];
	RNNModalManager* modalManager = [RNNModalManager new];
	RNNControllerFactory* controllerFactory = [[RNNControllerFactory alloc] initWithRootViewCreator:creator eventEmitter:eventEmmiter store:nil componentRegistry:nil andBridge:nil bottomTabsAttachModeFactory:[BottomTabsAttachModeFactory new]];
	RNNCommandsHandler* commandsHandler = [[RNNCommandsHandler alloc] initWithControllerFactory:controllerFactory eventEmitter:eventEmmiter modalManager:modalManager overlayManager:overlayManager mainWindow:window];
	[commandsHandler setReadyToReceiveCommands:YES];
	[commandsHandler setDefaultOptions:@{
		@"animations": @{
				@"push": @{
						@"enabled": @(0)
				},
				@"pop": @{
						@"enabled": @(0)
				}
		},
		@"topBar": @{
				@"drawBehind": @(1)
		},
		@"layout": @{
				@"componentBackgroundColor": @(0xFF00FF00)
		}
	} completion:^{}];
	
	return commandsHandler;
}

@end
