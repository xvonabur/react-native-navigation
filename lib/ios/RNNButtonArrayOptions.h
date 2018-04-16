#import "RNNOptions.h"
#import "RNNButtonOptions.h"

@interface RNNButtonArrayOptions : RNNOptions

@property (nonatomic, strong) NSArray* buttons;

- (void)mergeWith:(NSArray *)otherOptions defaultButtonOptions:(RNNButtonOptions *)defaultButtonOptions;

@end
