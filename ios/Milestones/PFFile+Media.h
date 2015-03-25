//
// Created by Nathan  Pahucki on 9/9/14.
// Copyright (c) 2015 InfantIQ.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaFile.h"

@interface PFFile (Media) <MediaFile>

+ (instancetype)imageFileFromImage:(UIImage *)image;

@end