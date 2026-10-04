#import <UIKit/UIKit.h>
#import <ObjectivePGP/ObjectivePGP.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor systemBackgroundColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 350, 40)];
    title.text = @"ObjectivePGP App";
    title.font = [UIFont boldSystemFontOfSize:28];
    title.textAlignment = NSTextAlignmentCenter;
    [vc.view addSubview:title];
    
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 350, 80)];
    status.numberOfLines = 0;
    status.textAlignment = NSTextAlignmentCenter;
    
    @try {
        PGPKeyring *keyring = [[PGPKeyring alloc] init];
        status.text = [NSString stringWithFormat:@"✅ ObjectivePGP loaded!\nKeyring keys: %lu", (unsigned long)keyring.keys.count];
        status.textColor = [UIColor systemGreenColor];
    } @catch (NSException *e) {
        status.text = [NSString stringWithFormat:@"❌ Error: %@", e.reason];
        status.textColor = [UIColor systemRedColor];
    }
    [vc.view addSubview:status];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
