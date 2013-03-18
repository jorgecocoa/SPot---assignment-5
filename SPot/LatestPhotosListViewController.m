//
//  LatestPhotosListViewController.m
//  SPot
//
//  Created by Jorge García-Luengo on 08/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import "LatestPhotosListViewController.h"
#import "FlickrFetcher.h"
#import "RecentPhotos.h"

@interface LatestPhotosListViewController ()

@end

@implementation LatestPhotosListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadRecentlySeenPhotos];
    //self.photos = [self findPhotos];
    [self.tableView reloadData];
}

- (void)loadRecentlySeenPhotos
{
    dispatch_queue_t recentPhotosQ = dispatch_queue_create("lost of recent photos", NULL);
    dispatch_async(recentPhotosQ, ^{
        NSArray *recentPhotosArray = [self findPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = recentPhotosArray;
        });
    });
}


//here we must retreave the photos that have been saved, or that have recently been seen!!
- (NSArray *)findPhotos
{
    NSMutableArray *allPhotosSaved = [[NSMutableArray alloc] initWithArray:[RecentPhotos allPhotosRecentlyViewed]];
    
    [allPhotosSaved sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    
    NSMutableArray *photosInArray = [[NSMutableArray alloc] initWithArray:[FlickrFetcher stanfordPhotos]];
    NSMutableArray *newPhotoArray = [[NSMutableArray alloc] init];
    
    for (int j=0;j<[allPhotosSaved count]; j++) {
        RecentPhotos *recentPhotoSaved = [allPhotosSaved objectAtIndex:j];
        for (int i=0; i<[photosInArray count]; i++) {
            if ([photosInArray[i][FLICKR_PHOTO_ID] isEqualToString:recentPhotoSaved.photoID]) {
                [newPhotoArray addObject:[photosInArray objectAtIndex:i]];
                [photosInArray removeObjectAtIndex:i];
            }
        }
        if (j>10) break;
    }
    [self.tableView reloadData];
    return [newPhotoArray copy];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photo"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url;
                    if (self.splitViewController) {
                        url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatOriginal];
                    } else {
                        url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                    }
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}

@end
