#import "RNNOptions.h"
#import "RNNTitleOptions.h"
#import "RNNSubtitleOptions.h"
#import "RNNBackgroundOptions.h"
#import "RNNComponentOptions.h"
#import "RNNButtonOptions.h"
#import "RNNButtonArrayOptions.h"
@interface RNNTopBarOptions : RNNOptions

@property (nonatomic, strong) RNNButtonArrayOptions* leftButtons;
@property (nonatomic, strong) RNNButtonArrayOptions* rightButtons;
@property (nonatomic, strong) NSNumber* visible;
@property (nonatomic, strong) NSNumber* hideOnScroll;
@property (nonatomic, strong) NSNumber* buttonColor;
@property (nonatomic, strong) NSNumber* translucent;
@property (nonatomic, strong) NSNumber* transparent;
@property (nonatomic, strong) NSNumber* drawBehind;
@property (nonatomic, strong) NSNumber* noBorder;
@property (nonatomic, strong) NSNumber* blur;
@property (nonatomic, strong) NSNumber* animate;
@property (nonatomic, strong) NSNumber* largeTitle;
@property (nonatomic, strong) NSString* testID;
@property (nonatomic, strong) RNNTitleOptions* title;
@property (nonatomic, strong) RNNSubtitleOptions* subtitle;
@property (nonatomic, strong) RNNBackgroundOptions* background;
@property (nonatomic, strong) RNNButtonOptions* button;
@property (nonatomic, strong) NSNumber* backButtonImage;
@property (nonatomic, strong) NSNumber* backButtonHidden;
@property (nonatomic, strong) NSString* backButtonTitle;
@property (nonatomic, strong) NSNumber* hideBackButtonTitle;

@property (nonatomic, strong) RNNComponentOptions* component;

@end
