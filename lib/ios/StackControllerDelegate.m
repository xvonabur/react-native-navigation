#import "StackControllerDelegate.h"
#import "StackTransitionDelegate.h"
#import "UIViewController+LayoutProtocol.h"

@implementation StackControllerDelegate {
    RNNEventEmitter* _eventEmitter;
    UIViewController* _presentedViewController;
}

- (instancetype)initWithEventEmitter:(RNNEventEmitter *)eventEmitter {
    self = [super init];
    _eventEmitter = eventEmitter;
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController.viewControllers indexOfObject:_presentedViewController] < 0) {
        [self sendScreenPoppedEvent:_presentedViewController];
    }
    
    _presentedViewController = viewController;
}

- (void)sendScreenPoppedEvent:(UIViewController *)poppedScreen {
    [_eventEmitter sendScreenPoppedEvent:poppedScreen.layoutInfo.componentId];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController*)fromVC
												 toViewController:(UIViewController*)toVC {
	if (operation == UINavigationControllerOperationPush && toVC.resolveOptions.animations.push.hasCustomAnimation) {
		return [[StackTransitionDelegate alloc] initWithScreenTransition:toVC.resolveOptions.animations.push uiManager:_eventEmitter.bridge.uiManager];
	} else if (operation == UINavigationControllerOperationPop && fromVC.resolveOptions.animations.pop.hasCustomAnimation) {
		return [[StackTransitionDelegate alloc] initWithScreenTransition:fromVC.resolveOptions.animations.pop uiManager:_eventEmitter.bridge.uiManager];
	} else {
		return nil;
	}
	
	return nil;
}


@end
