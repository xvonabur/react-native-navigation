#import "RNNButtonOptions.h"

@implementation RNNButtonOptions

- (void)mergeWith:(NSDictionary *)otherOptions {
	[super mergeWith:otherOptions];
	
	if (otherOptions[@"id"]) {
		self.buttonID = otherOptions[@"id"];
	}
	
	if (otherOptions[@"component"][@"name"]) {
		self.componentName = otherOptions[@"component"][@"name"];
	}
}


@end
