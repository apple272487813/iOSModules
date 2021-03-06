//
//  IMPhotosPreviewViewController.m
//  iOSModules
//
//  Created by 石城磊 on 30/12/2017.
//  Copyright © 2017 石城磊. All rights reserved.
//

#import "IMPhotosPreviewViewController.h"
#import "IMPhotosManager.h"
#import "IMPhotoPreviewCollectionViewCell.h"

static NSString * const IMPhotoPreviewCVCID =   @"IMPhotoPreviewCVCID";

@interface IMPhotosPreviewViewController ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>

@property (nonatomic, assign)  BOOL                                            isHideOtherUI;
@property (nonatomic, strong)  UICollectionView                                *photosCollectionView;
@property (nonatomic, strong)  NSMutableArray <id <IMPhotoProtocol>>           *photosMutArray;

@property (nonatomic, strong)  UIButton                                        *selectButton;
@property (nonatomic, strong)  NSMutableSet                                    *selectedMutSet;
@property (nonatomic, strong)  UIView                                          *bottomBarView;
@property (nonatomic, strong)  UIScrollView                                    *selectedPhotoThumbnailView;
@property (nonatomic, strong)  UIButton                                        *photoEditButton;
@property (nonatomic, strong)  UIButton                                        *completePickButton;

@end

@implementation IMPhotosPreviewViewController

#pragma mark -
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViewApperance];
    [self initialPhotosData];
}

#pragma mark -
#pragma mark - Private methods
- (void)configureViewApperance {
    //
    UIImage *backgroundImage    =   [UIImage createTranslucenceImageWithSize:CGSizeMake(ScreenWidth, 64.0f)
                                                                       alpha:0.80f
                                                                      colorR:255.0f
                                                                      colorG:255.0f
                                                                      colorB:255.0f];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f],
                                                                      NSForegroundColorAttributeName:[UIColor blackColor]
                                                                      }];
    self.navigationItem.leftBarButtonItem  =   [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"im_arrow_left"]
                                                                                style:UIBarButtonItemStylePlain target:self action:@selector(backItemAction)];
    self.selectButton                =    [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.selectButton setTintColor:[UIColor clearColor]];
    [self.selectButton setSelected:NO];
    [self.selectButton setBackgroundImage:[UIImage imageNamed:@"im_select"] forState:UIControlStateSelected];
    [self.selectButton setBackgroundImage:[UIImage imageNamed:@"im_deselect"] forState:UIControlStateNormal];
    [self.selectButton setFrame:CGRectMake(0.0f, 10.0f, 24.0f, 24.0f)];
    [self.selectButton addTarget:self action:@selector(didSelectedCurrentShowPhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem =    [[UIBarButtonItem alloc] initWithCustomView:self.selectButton];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //
    self.isHideOtherUI          =   NO;
    //
    [self.view addSubview:self.photosCollectionView];
}

- (void)initialPhotosData {
    NSInteger totalPhotoCount   =   0;
    switch (self.previewType) {
        case IMPhotosPreviewTypeAlbumPhotos:
        {
            NSArray *imageAssetsArray    =   [IMPhotoManagerInstance loadPhotosFromAlbum:self.album.albumCollection
                                                                              targetSize:CGSizeMake(ScreenWidth, ScreenHeight)];
            [self.photosMutArray addObjectsFromArray:imageAssetsArray];
        }
            break;
        case IMPhotosPreviewTypeSelectedPhotos:
        {
            if (self.selectedPhotosArray.count > 0) {
                [self.photosMutArray addObjectsFromArray:self.selectedPhotosArray];
            }
        }
            break;
        default:
            break;
    }
    totalPhotoCount =   [self.photosMutArray count];
    [self.photosCollectionView setContentSize:CGSizeMake(ScreenWidth*self.photosMutArray.count, ScreenHeight)];
    [self.photosCollectionView reloadData];
    
    if (self.selectedPhotoIndex > 0) {
        [self.photosCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPhotoIndex inSection:0]
                                          atScrollPosition:UICollectionViewScrollPositionRight
                                                  animated:YES];
        NSString *titleString   =   [NSString stringWithFormat:@"%li / %li",(long)self.selectedPhotoIndex,(long)totalPhotoCount];
        self.title              =   titleString;
    }
    
    
}
- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideOtherUI {
    if (!self.isHideOtherUI) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect navigationBarRect  =   self.navigationController.navigationBar.frame;
            self.navigationController.navigationBar.frame   =   CGRectMake(navigationBarRect.origin.x, navigationBarRect.origin.y-64.0f, navigationBarRect.size.width, navigationBarRect.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect navigationBarRect  =   self.navigationController.navigationBar.frame;
            self.navigationController.navigationBar.frame   =   CGRectMake(navigationBarRect.origin.x, navigationBarRect.origin.y+64.0f, navigationBarRect.size.width, navigationBarRect.size.height);
        }];
    }
    self.isHideOtherUI  =   !self.isHideOtherUI;
}

- (void)didSelectedCurrentShowPhoto {
    self.selectButton.selected  =   !self.selectButton.selected;
    IMPhoto *aPhoto =   self.photosMutArray[self.selectedPhotoIndex];
    if (self.selectButton.selected) {
        if (![self.selectedMutSet containsObject:aPhoto]) {
            [self.selectedMutSet addObject:aPhoto];
        }
    } else {
        if ([self.selectedMutSet containsObject:aPhoto]) {
            [self.selectedMutSet removeObject:aPhoto];
        }
    }
    IMDebugLog(@"Now selected index %ld photo mut arr = %@",(long)self.selectedPhotoIndex,self.selectedMutSet);
}

#pragma mark -
#pragma mark - UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosMutArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IMPhotoPreviewCollectionViewCell *photoPreviceCVC   =   [collectionView dequeueReusableCellWithReuseIdentifier:IMPhotoPreviewCVCID forIndexPath:indexPath];
    [photoPreviceCVC configurePhotoPreviewCVCWithPhoto:self.photosMutArray[indexPath.row]];
    [photoPreviceCVC setPhotoViewTapHandler:^{
        [self hideOtherUI];
    }];
    return photoPreviceCVC;
}

#pragma mark - UICollectionViewCellDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(IMPhotoPreviewCollectionViewCell *)cell resetContentViewScale];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat contentOffSetX  =   scrollView.contentOffset.x;
    NSInteger showIndex     =   contentOffSetX/CGRectGetWidth(self.view.frame);
    self.selectedPhotoIndex =   showIndex;
    NSString *titleString   =   [NSString stringWithFormat:@"%li / %li",(long)self.selectedPhotoIndex,(long)self.photosMutArray.count];
    self.title              =   titleString;
    self.selectButton.selected       =   NO;
    IMPhoto *currentPhoto   =   self.photosMutArray[self.selectedPhotoIndex];
    if ([self.selectedMutSet containsObject:currentPhoto]) {
        self.selectButton.selected  =   YES;
    }
}


#pragma mark -
#pragma mark - Initializations
- (UICollectionView *)photosCollectionView {
    if (!_photosCollectionView) {
        UICollectionViewFlowLayout  *flowLayout =   [[UICollectionViewFlowLayout alloc] init];
        CGSize  itemSize                        =   CGSizeMake(ScreenWidth, ScreenHeight);
        flowLayout.minimumLineSpacing           =   0.0f;
        flowLayout.minimumInteritemSpacing      =   0.0f;
        flowLayout.sectionInset                 =   UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        flowLayout.itemSize                     =   itemSize;
        flowLayout.scrollDirection              =   UICollectionViewScrollDirectionHorizontal;
        _photosCollectionView                   =   [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        //
        if (@available(iOS 11.0, *)) {
            _photosCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } 
        
        _photosCollectionView.backgroundColor   =   [UIColor whiteColor];
        _photosCollectionView.pagingEnabled     =   YES;
        _photosCollectionView.delegate          =   self;
        _photosCollectionView.dataSource        =   self;
        [_photosCollectionView registerClass:[IMPhotoPreviewCollectionViewCell class] forCellWithReuseIdentifier:IMPhotoPreviewCVCID];
    }
    return _photosCollectionView;
}

- (NSMutableArray<id<IMPhotoProtocol>> *)photosMutArray {
    if (!_photosMutArray) {
        _photosMutArray =   [[NSMutableArray alloc] init];
    }
    return _photosMutArray;
}

- (NSMutableSet *)selectedMutSet {
    if (!_selectedMutSet) {
        _selectedMutSet =   [[NSMutableSet alloc] init];
    }
    return _selectedMutSet;
}

- (UIView *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView  =   [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.view.frame)-40.0f, ScreenWidth, 40.0f)];
        [_bottomBarView setBackgroundColor:RGBACOLOR(255.0f, 255.0f, 255.0f, 0.5)];
    }
    return _bottomBarView;
}

- (UIButton *)photoEditButton {
    if (!_photoEditButton) {
        _photoEditButton    =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    return _photoEditButton;
}

- (UIButton *)completePickButton {
    if (!_completePickButton) {
        _completePickButton =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    return _completePickButton;
}

@end
