//
//  NativeResultViewController.m
//  Navigation
//
//  Created by Listen on 2017/11/26.
//  Copyright © 2017年 Listen. All rights reserved.
//

#import "NativeResultViewController.h"

@interface NativeResultViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;

@end

@implementation NativeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"native result";
    
    if (![self.navigator canPop]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    }
    
    BOOL isRoot = self == self.navigationController.childViewControllers[0];
    self.backToHomeButton.enabled = !isRoot;
    
}

- (IBAction)sendResult:(UIButton *)sender {
    [self.navigator setResultCode:RESULT_OK data:@{@"text": self.resultTextField.text}];
    [self.navigator dismissAnimated:YES];
}

- (IBAction)pushToRN:(UIButton *)sender {
    [self.navigator pushModule:@"ReactResult" props:@{@"homeId": [self homeId]} options:@{} animated:YES];
}

- (IBAction)pushToNative:(UIButton *)sender {
    [self.navigator pushModule:@"NativeResult" props:@{@"homeId": [self homeId]} options:@{} animated:YES];
}

- (IBAction)replaceWithRN:(UIButton *)sender {
    BOOL isRoot = self == self.navigationController.childViewControllers[0];
    if (isRoot) {
        [self.navigator replaceModule:@"ReactResult"];
    } else {
        [self.navigator replaceModule:@"ReactResult" props:@{@"homeId": [self homeId]} options:@{}];
    }
}

- (IBAction)replaceToRootWithRN:(UIButton *)sender {
    [self.navigator replaceToRootModule:@"ReactResult"];
}

- (IBAction)backToHome:(UIButton *)sender {
    NSString *homeId =  [self.props objectForKey:@"homeId"];
    if (homeId) {
        [self.navigator popToScene:homeId animated:YES];
    }
}

- (NSString *)homeId {
    NSString *homeId = [self.props objectForKey:@"homeId"];
    if (!homeId) {
        homeId = self.sceneId;
    }
    return homeId;
}

- (void)cancel {
    [self.navigator dismissAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
