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
#import <SVPullToRefresh.h>

#define FSWeakSelf __weak typeof(self) weakSelf = self;

@interface FSMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation FSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"cell-AutoHeight";
    self.view.backgroundColor = [UIColor whiteColor];
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
        make.top.equalTo(self.view.mas_top).with.offset(64);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    FSWeakSelf
    [_tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertWithTop];
    }];
    
    [_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertWithBottom];
    }];
}

#pragma mark - data
- (void)insertWithTop
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"feed"];
        
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FDFeedEntity alloc] initWithDictionary:obj]];
        }];
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:entities];
        [self.tableView.pullToRefreshView stopAnimating];
        [self.tableView reloadData];
    });
}

- (void)insertWithBottom
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"feed"];
        
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FDFeedEntity alloc] initWithDictionary:obj]];
        }];
        [self.datas addObjectsFromArray:entities];
        [self.tableView.infiniteScrollingView stopAnimating];
        //    [self.tableView reloadData];
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc]init];
        for (int ind = 0; ind < [entities count]; ind++)
        {
            NSIndexPath *newPath =  [NSIndexPath indexPathForRow:[_datas indexOfObject:[entities objectAtIndex:ind]] inSection:0];
            [insertIndexPaths addObject:newPath];
        }
        [_tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
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
    CGFloat height = [FSTestTableViewCell FSCellHeightForTableView:tableView indexPath:indexPath cellContentViewWidth:0];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FSTestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[FSTestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.entity = _datas[indexPath.row];
        return cell;
    }
    FSTestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    if (!cell) {
        cell = [[FSTestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
    }
    cell.entity = _datas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
