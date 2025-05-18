#import "NativeViewController.h"

@interface NativeViewController ()

@end

@implementation NativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.props[@"greeting"] ?: @"Native";
    
    if (self.props[@"greeting"]) {
        self.hbd_barTintColor = [UIColor redColor];
    }
}

- (IBAction)pushToRN:(UIButton *)sender {
    if (self.navigationController) {
        NSDictionary *passedProps = nil;
        if(self.props[@"popToId"]) {
            passedProps = @{@"popToId": self.props[@"popToId"]};
        }
        else {
            passedProps = @{@"popToId": self.sceneId};
        }
        HBDViewController *vc = [[HBDReactBridgeManager get] viewControllerWithModuleName:@"Navigation" props:passedProps options:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pushToNative:(UIButton *)sender {
    if (self.navigationController) {
        NSDictionary *passedProps = nil;
        if(self.props[@"popToId"]) {
            passedProps = @{@"popToId": self.props[@"popToId"], @"greeting": @"Hello, Native"};
        }
        else {
            passedProps = @{@"popToId": self.sceneId, @"greeting": @"Hello, Native"};
        }
        NativeViewController *vc = [[NativeViewController alloc] initWithModuleName:nil props:passedProps options:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
