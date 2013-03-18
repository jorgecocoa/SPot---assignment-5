//
//  PhotoCache.h
//  SPot
//
//  Created by Jorge García-Luengo on 16/03/13.
//  Copyright (c) 2013 Jorge García-Luengo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoCache : NSObject


- (NSData *)retrivePhotosFromCacheWithURL:(NSURL *)photoURL;


- (void)putPhotosInCahe:(NSData *)photoData toURL:(NSURL *)photoURL;



@end
