//
//  RecentPhotos.h
//  SPot
//
//  Created by Jorge García-Luengo on 10/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentPhotos : NSObject

+ (NSArray *)allPhotosRecentlyViewed;

@property (readonly, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *photoID;

@end
