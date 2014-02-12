//
//  PhotoViewController.m
//  CellScope
//
//  Created by Matthew Bakalar on 8/22/12.
//  Copyright (c) 2012 Matthew Bakalar. All rights reserved.
//

#import "PhotoViewController.h"
#import "CoreDataHelper.h"
#import "Pictures.h"
#import "NIPageView.h"
#import "NIPhotoScrollView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation PhotoViewController

@synthesize managedObjectContext;
@synthesize thumbnailImageCache;
@synthesize highQualityImageCache;
@synthesize assetsLibrary;

#pragma mark - UIView

- (void)loadView {
    [super loadView];
    
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    highQualityImageCache = [[NIImageMemoryCache alloc] init];
    thumbnailImageCache = [[NIImageMemoryCache alloc] init];
    
    [highQualityImageCache setMaxNumberOfPixels:1024L*1024L*10L];
    [highQualityImageCache setMaxNumberOfPixelsUnderStress:1024L*1024L*3L];
    
    self.photoAlbumView.dataSource = self;
    self.photoAlbumView.zoomingAboveOriginalSizeIsEnabled = YES;
    
    // This title will be displayed until we get the results back for the album information.
    self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");
    
    [self loadAlbumInformation];
}

- (void)loadAlbumInformation
{
    //  Grab the data
    self.pictureListData = [CoreDataHelper getObjectsForEntity:@"Pictures" withSortKey:@"title" andSortAscending:YES andContext:managedObjectContext];
    [self.photoAlbumView reloadData];
    [self.photoScrubberView reloadData];
}

/**
 * Fetches the highest-quality image available for the photo at the given index.
 *
 * Your goal should be to make this implementation return as fast as possible. Avoid
 * hitting the disk or blocking on a network request. Aim to load images asynchronously.
 *
 * If you already have the highest-quality image in memory (like in an NIImageMemoryCache),
 * then you can simply return the image and set photoSize to be
 * NIPhotoScrollViewPhotoSizeOriginal.
 *
 * If the highest-quality image is not available when this method is called then you should
 * spin off an asynchronous operation to load the image and set isLoading to YES.
 *
 * If you have a thumbnail in memory but not the full-size image yet, then you should return
 * the thumbnail, set isLoading to YES, and set photoSize to NIPhotoScrollViewPhotoSizeThumbnail.
 *
 * Once the high-quality image finishes loading, call didLoadPhoto:atIndex:photoSize: with
 * the image.
 *
 * This method will be called to prefetch the next and previous photos in the scroll view.
 * The currently displayed photo will always be requested first.
 *
 *      @attention The photo scroll view does not hold onto the UIImages for very long at all.
 *                 It is up to the controller to decide on an adequate caching policy to ensure
 *                 that images are kept in memory through the life of the photo album.
 *                 In your implementation of the data source you should prioritize thumbnails
 *                 being kept in memory over full-size images. When a memory warning is received,
 *                 the original photos should be relinquished from memory first.
 */
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions
{
    Pictures* picture = [self.pictureListData objectAtIndex:photoIndex];
    UIImage* thumbnail = [UIImage imageWithData:picture.smallPicture];
    UIImage* fullSize;
    
    _requestedURL = picture.path;
    NSURL *asseturl = [NSURL URLWithString:picture.path];
    NIImageMemoryCache *imageCache = self.highQualityImageCache;

    if ([self.highQualityImageCache containsObjectWithName:_requestedURL]) {
        fullSize = [self.highQualityImageCache objectWithName:_requestedURL];
    }
    else {
        // Request full size image from Assets library
        /*
        [assetsLibrary assetForURL:asseturl
            resultBlock:resultblock
           failureBlock:failureblock];
        
        *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;
        *isLoading = YES;
        //fullSize = thumbnail;
         */
    }
    return thumbnail;
}


ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
{
    UIImage *fullImage;
    
    // asset = myasset;
    // get the image
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    if (iref) {
        fullImage = [UIImage imageWithCGImage:iref];
        //[highQualityImageCache storeObject: imagewithName: picture.path];
    }
};

ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
{
    NSLog(@"Failed to load image from asset's library - %@",[myerror localizedDescription]);
};


- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
    return [NSString stringWithFormat:@"%d", photoIndex];
}

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView
{
    return self.pictureListData.count;
}

- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
    return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}

@end
