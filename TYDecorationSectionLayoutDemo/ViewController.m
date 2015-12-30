//
//  ViewController.m
//  TYDecorationSectionLayoutDemo
//
//  Created by tanyang on 15/12/29.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYDecorationSectionLayout.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.items = @[@(28), @(3), @(10), @(16), @(2), @(5), @(20)];
    
    [self addCollectionView];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)addCollectionView
{
    TYDecorationSectionLayout *layout = [[TYDecorationSectionLayout alloc]init];
    //layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.alternateDecorationViews = YES;
    // costom xib names
    layout.decorationViewOfKinds = @[@"ThirdDecorationSectionView",@"FirstDecorationSectionView",@"SecondDecorationSectionView"];
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor lightGrayColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _collectionView.frame = self.view.bounds;
}

#pragma mark - UICollectionView DataSource Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items[section] integerValue];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:(rand()%255)/255.0 alpha:1.0];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return  UIEdgeInsetsMake(8.f, 10.f, 8.f, 10.f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
