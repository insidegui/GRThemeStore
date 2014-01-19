//
//  GRThemeStore.h
//  packtheme
//
//  Created by Guilherme Rambo on 03/11/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSData+ZLib.h"
#import "ThemeFile.h"
#import "GRThemePiece.h"

@interface GRThemeStore : NSObject

// initializes the theme store using a .pack file
- (id)initWithCompressedPackageData:(NSData *)data;

// returns an image from the theme, works just like [NSImage imageNamed:]
- (NSImage *)imageNamed:(NSString *)name;

// an array containing all of the currently loaded theme's pieces
@property (nonatomic, copy) NSArray *themePieces;

@end
