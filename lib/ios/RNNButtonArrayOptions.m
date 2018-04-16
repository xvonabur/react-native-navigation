#import "RNNButtonArrayOptions.h"

@implementation RNNButtonArrayOptions

- (void)mergeWith:(NSArray *)otherOptions defaultButtonOptions:(RNNButtonOptions *)defaultButtonOptions {
	if (otherOptions && [otherOptions isKindOfClass:[NSArray class]]) {
		NSMutableArray* mutableButtonsArray = [[NSMutableArray alloc] init];
		for (NSDictionary* buttonDict in otherOptions) {
			RNNButtonOptions* button = [[RNNButtonOptions alloc] initWithDict:buttonDict];
			[button mergeWithObject:defaultButtonOptions];
			[mutableButtonsArray addObject:button];
		}
		
		self.buttons = mutableButtonsArray;
	}
}

- (void)mergeWith:(NSDictionary *)otherOptions {
	
}

@end
