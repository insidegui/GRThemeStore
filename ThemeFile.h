//
//  ThemeFile.h
//  packtheme
//
//  Created by Guilherme Rambo on 03/11/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#ifndef packtheme_ThemeFile_h
#define packtheme_ThemeFile_h

// .pack file header
typedef struct __attribute__((__packed__)) master_header {
    char signature[4]; // 'TPKG'
    char version; // currently 1
    unsigned long entries_offset;
    unsigned long start_offset;
    char reserved[16]; // not used
} master_header_t;

#endif
