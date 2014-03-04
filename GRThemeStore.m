//
//  GRThemeStore.m
//  packtheme
//
//  Created by Guilherme Rambo on 03/11/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import "GRThemeStore.h"

@implementation GRThemeStore
{
    master_header_t *_themeHeader;
    
    NSData *_compressedData;
    NSData *_data;
    NSData *_plistData;
    NSArray  *_entries;
}

- (id)initWithCompressedPackageData:(NSData *)data
{
    self = [super init];
    
    if (!self) return nil;
    
    _compressedData = data;
    
    [self parseData];
    
    return self;
}

- (void)parseData
{
    _data = [_compressedData zlibInflate];
    
    if (!_data) {
        NSLog(@"ThemeStore: failed to decompress theme file!");
        return;
    }
    
    _themeHeader = (master_header_t *)[[_data subdataWithRange:NSMakeRange(0, sizeof(master_header_t))] bytes];
    if (![self headerSanityCheck]) {
        NSLog(@"ThemeStore: Header sanity check failed!");
        return;
    } else {
        #ifdef DEBUG
        NSLog(@"ThemeStore: Header sanity check succeeded!");
        #endif
    }
    
    _plistData = [_data subdataWithRange:NSMakeRange(_themeHeader->entries_offset, _themeHeader->start_offset-sizeof(master_header_t))];
    if (!_plistData) {
        NSLog(@"ThemeStore: Failed to read plist data!");
        return;
    } else {
        #ifdef DEBUG
        NSLog(@"ThemeStore: Plist data read successfully!");
        NSLog(@"Plist length: %ld", _plistData.length);
        #endif
    }

    _entries = [NSKeyedUnarchiver unarchiveObjectWithData:_plistData];
    if (!_entries) {
        NSLog(@"ThemeStore: Failed to unarchive plist data!");
        return;
    } else {
        #ifdef DEBUG
        NSLog(@"ThemeStore: Plist data unarchived successfully!");
        NSLog(@"%@", _entries);
        #endif
    }
    
    NSMutableArray *pieces = [[NSMutableArray alloc] init];
    for (NSDictionary *entry in _entries) {
        unsigned long offset = [entry[@"offset"] unsignedLongValue];
        unsigned long length = [entry[@"length"] unsignedLongValue];
        NSData *file = [_data subdataWithRange:NSMakeRange(_themeHeader->start_offset+offset, length)];
        NSImage *image = [[NSImage alloc] initWithData:file];
        
        GRThemePiece *piece = [GRThemePiece themePieceWithFilename:entry[@"filename"] image:image];

        [pieces addObject:piece];
        
        #ifdef DEBUG
        NSLog(@"Extracted piece %@", piece.name);
        #endif
    }
    
    self.themePieces = [[NSArray alloc] initWithArray:pieces];
    
    #ifdef DEBUG
    NSLog(@"%@", self.themePieces);
    #endif
}

- (NSImage *)imageNamed:(NSString *)name
{
    BOOL isRetina = NO;
    // detect retina display
    if ([[NSScreen mainScreen] backingScaleFactor] > 1) isRetina = YES;
    
    GRThemePiece *piece;
    
    // try to get a @2x version of the image if we are on retina
    if (isRetina) piece = [[self.themePieces filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", [name stringByAppendingString:@"@2x"]]] lastObject];
    
    // fallback to default image if @2x is not found, or if we are not on retina
    if (!piece) piece = [[self.themePieces filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]] lastObject];
    
    return [piece image];
}

- (BOOL)headerSanityCheck
{
    #ifdef DEBUG
    NSLog(@"Header info:");
    NSLog(@"Signature: %c%c%c%c", _themeHeader->signature[0], _themeHeader->signature[1], _themeHeader->signature[2], _themeHeader->signature[3]);
    NSLog(@"Version: %d", _themeHeader->version);
    NSLog(@"Entries offset: %ld", _themeHeader->entries_offset);
    NSLog(@"Start offset: %ld", _themeHeader->start_offset);
    #endif
    
    if (_themeHeader->signature[3] != 'G' || !_themeHeader->entries_offset || !_themeHeader->start_offset) {
        return NO;
    } else {
        return YES;
    }
}

@end
