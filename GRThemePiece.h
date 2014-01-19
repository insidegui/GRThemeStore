//
//  GRThemePiece.h
//  packtheme
//
//  Created by Guilherme Rambo on 03/11/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// this represents an image inside a theme file,
// it is not meant to be used directly, it is used by GRThemeStore

@interface GRThemePiece : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSImage *image;

+ (GRThemePiece *)themePieceWithFilename:(NSString *)aFilename image:(NSImage *)anImage;

@end
