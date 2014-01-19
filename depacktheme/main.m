//
//  main.m
//  depacktheme
//
//  Created by Guilherme Rambo on 03/11/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GRThemeStore.h"

void print_usage();

GRThemeStore *_themeStore;

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        if (argc < 3) {
            print_usage();
            return 0;
        }
        
        NSString *inFile = [NSString stringWithUTF8String:argv[1]];
        NSString *outDir = [NSString stringWithUTF8String:argv[2]];
        
        NSLog(@"%@ -> %@", inFile, outDir);
        
        _themeStore = [[GRThemeStore alloc] initWithCompressedPackageData:[NSData dataWithContentsOfFile:inFile]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:outDir isDirectory:nil]) {
            NSError *dirCreateError;
            [[NSFileManager defaultManager] createDirectoryAtPath:outDir withIntermediateDirectories:NO attributes:nil error:&dirCreateError];
            
            if (dirCreateError) {
                NSLog(@"Failed to create directory! %@", dirCreateError);
                return 1;
            }
        }
        
        for (GRThemePiece *piece in _themeStore.themePieces) {
            [[piece.image TIFFRepresentation] writeToFile:[NSString pathWithComponents:@[outDir, piece.filename]] atomically:YES];
        }
        
        NSLog(@"DONE!");
    }
    return 0;
}

void print_usage()
{
    printf("Usage: depacktheme themefile outputdir\n");
}