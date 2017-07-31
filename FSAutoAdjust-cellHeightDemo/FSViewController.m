//
//  FSViewController.m
//  FSAutoAdjust-cellHeightDemo
//
//  Created by 冯顺 on 2017/7/31.
//  Copyright © 2017年 shunFSKi. All rights reserved.
//

#import "FSViewController.h"
#import "FSMainViewController.h"
#import <Masonry.h>

@interface FSViewController ()

@end

@implementation FSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"cell-AutoHeight";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *indexPathCacheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [indexPathCacheBtn setTitle:@"indexPathCacheBtn" forState:UIControlStateNormal];
    indexPathCacheBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [indexPathCacheBtn sizeToFit];
    [self.view addSubview:indexPathCacheBtn];
    [indexPathCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.equalTo(self.view.mas_top).with.offset(200);
    }];
    
    UIButton *keyCacheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyCacheBtn setTitle:@"keyCacheBtn" forState:UIControlStateNormal];
    keyCacheBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [keyCacheBtn sizeToFit];
    [self.view addSubview:keyCacheBtn];
    [keyCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.equalTo(indexPathCacheBtn.mas_bottom).with.offset(20);
    }];
    
    [indexPathCacheBtn addTarget:self action:@selector(indexPathCacheBtn) forControlEvents:UIControlEventTouchUpInside];
    [keyCacheBtn addTarget:self action:@selector(keyCacheBtn) forControlEvents:UIControlEventTouchUpInside];
    
    indexPathCacheBtn.backgroundColor = [UIColor blackColor];
    keyCacheBtn.backgroundColor = [UIColor blackColor];
}


- (void)indexPathCacheBtn
{
    FSMainViewController *mainVC = [[FSMainViewController alloc]init];
    mainVC.title = @"indexPathCache";
    [self.navigationController pushViewController:mainVC animated:YES];
}

- (void)keyCacheBtn
{
    FSMainViewController *mainVC = [[FSMainViewController alloc]init];
    mainVC.title = @"keyCache";
    [self.navigationController pushViewController:mainVC animated:YES];
}

@end
