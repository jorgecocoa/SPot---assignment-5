//
//  RecentPhotos.m
//  SPot
//
//  Created by Jorge García-Luengo on 10/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import "RecentPhotos.h"
#import "FlickrFetcher.h"

@interface RecentPhotos ()
@property (readwrite, nonatomic) NSDate *date;

@end

@implementation RecentPhotos

#define ALL_PHOTOS_KEY @"seenPhotos_ALL"

- (id)init
{
    self = [super init];
    if (self) {
        _date = [NSDate date];
        _photoID = @"";
    }
    return self;
}

- (void)synchronize
{
    NSMutableDictionary *mutableRecentPhotosUserDefaults= [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_PHOTOS_KEY] mutableCopy];
    if (!mutableRecentPhotosUserDefaults) mutableRecentPhotosUserDefaults = [[NSMutableDictionary alloc] init];
    mutableRecentPhotosUserDefaults[[self.photoID description]] = [self asPropertyList];
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecentPhotosUserDefaults forKey:ALL_PHOTOS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#define WATCHED_DATE @"date"
#define PHOTO_ID @"photo_id"

- (id)asPropertyList
{
    return @{WATCHED_DATE: self.date, PHOTO_ID: self.photoID};
}

- (void)setPhotoID:(NSString *)photoID
{
    if (!_photoID) _photoID = [[NSString alloc] init];
        _photoID = photoID;
    [self synchronize];
}

+ (NSArray *)allPhotosRecentlyViewed
{
    NSMutableArray *allPhotosRecentlyViewed = [[NSMutableArray alloc] init];

    for (id plist in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:ALL_PHOTOS_KEY] allValues]) {
        RecentPhotos *recentPhoto = [[RecentPhotos alloc] initFromPropertyList:plist];
        [allPhotosRecentlyViewed addObject:recentPhoto];
    }

    return allPhotosRecentlyViewed;
}

//convenience initializer
- (id)initFromPropertyList:(id)propertyList
{
    self =[self init];
    if (self) {
        if ([propertyList isKindOfClass:[NSDictionary class]]) {
            NSDictionary *photosDictionary = (NSDictionary *)propertyList;
            _date = photosDictionary[WATCHED_DATE];
            _photoID = photosDictionary[PHOTO_ID];
            if (!_date || !_photoID) self = nil;
        }
    }
    return self;
    
}

@end
