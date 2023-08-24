//
//  ViewController.m
//  SocketConnect
//
//  Created by TigerHu on 2023/8/23.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *mainTable;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"SocketConnect";
    
    [self setupView];
    
    [self setupData];
}

- (void)setupView {
    self.mainTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.mainTable.dataSource = self;
    self.mainTable.delegate   = self;
    [self.mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mainTableCell"];
    if (@available(iOS 11.0, *)) {
        self.mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.mainTable];
}

- (void)setupData {
    self.dataList = @[@{@"text"  : @"StreamSocket使用",
                        @"class" : @"KJStreamSocketConnectVC"},
                      @{@"text"  : @"GCDAsyncSocket使用",
                        @"class" : @"KJGCDAsyncSocketConnectVC"},
                      @{@"text"  : @"SmartLink使用",
                        @"class" : @"KJSmartLinkConnectVC"},
                      @{@"text"  : @"ULink使用",
                        @"class" : @"KJULinkConnectVC"},
                     
    ];
    
    [self.mainTable reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.mainTable.frame = self.view.bounds;
    CGRect newFrame =  self.mainTable.frame;
    newFrame.origin.y = 100;
    newFrame.size.height = newFrame.size.height - 100;
    self.mainTable.frame = newFrame;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainTableCell"];
    NSDictionary *dic = self.dataList[indexPath.row];
    cell.textLabel.text = dic[@"text"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataList[indexPath.row];
    Class cls = NSClassFromString(dic[@"class"]);
    UIViewController *vc = [cls new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
