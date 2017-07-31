//
//  FSMainViewController.m
//  FSAutoAdjust-cellHeightDemo
//
//  Created by huim on 2017/7/7.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import "FSMainViewController.h"
#import "FSTestTableViewCell.h"
#import "UITableViewCell+FSAutoCountHeight.h"
#import "FSEntity.h"
#import <MJRefresh.h>

#define FSWeakSelf __weak typeof(self) weakSelf = self;

@interface FSMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) BOOL isDebug;
@end

@implementation FSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"debug" style:UIBarButtonItemStylePlain target:self action:@selector(debugButtonClick)];
    [self setupSubViews];
    [self insertWithTop];
}

- (void)setupSubViews
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    FSWeakSelf
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf insertWithTop];
    }];
    
    _tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
        [weakSelf insertWithBottom];
    }];
    
}

#pragma mark - Btn
- (void)debugButtonClick
{
    self.isDebug = !self.isDebug;
    [self.tableView reloadData];
}

#pragma mark - data
- (void)insertWithTop
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"shunfski"];
        
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FSEntity alloc] initWithDictionary:obj]];
        }];
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:entities];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    });
}

- (void)insertWithBottom
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"shunfski"];
        
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FSEntity alloc] initWithDictionary:obj]];
        }];
        [self.datas addObjectsFromArray:entities];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    });
    
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSEntity *entity = _datas[indexPath.row];
    CGFloat height = [self.title isEqualToString:@"keyCache"]?[FSTestTableViewCell FSCellHeightForTableView:tableView indexPath:indexPath cacheKey:entity.identifier cellContentViewWidth:0 bottomOffset:0]:[FSTestTableViewCell FSCellHeightForTableView:tableView indexPath:indexPath cellContentViewWidth:0 bottomOffset:0];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FSTestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[FSTestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.isDebug = self.isDebug;
        cell.entity = _datas[indexPath.row];
        return cell;
    }
    FSTestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    if (!cell) {
        cell = [[FSTestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
    }
    cell.isDebug = self.isDebug;
    cell.entity = _datas[indexPath.row];
    return cell;
}

#pragma mark - Lazyload

- (NSMutableArray *)datas
{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

@end
