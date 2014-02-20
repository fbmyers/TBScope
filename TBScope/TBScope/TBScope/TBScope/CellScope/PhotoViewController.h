//
//  PhotoViewController.h
//  CellScope
//
//  Created by Matthew Bakalar on 8/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "NIToolbarPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class CSUserContext;

@interface PhotoViewController : NIToolbarPhotoViewController <NIPhotoAlbumScrollViewDataSource> {
    NSString *_requestedURL;
    ALAsset *_asset;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CSUserContext *userContext;
@property (nonatomic, strong) NSMutableArray *pictureListData;

@property (nonatomic, strong) NIImageMemoryCache* thumbnailImageCache;
@property (nonatomic, strong) NIImageMemoryCache* highQualityImageCache;

@property (nonatomic, strong) ALAssetsLibrary* assetsLibrary;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;


- (void)loadAlbumInformation;

@end
