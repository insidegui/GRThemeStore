//
//  main.m
//  packtheme
//
//  Created by Guilherme Rambo on 03/11/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

/*
 THEME FILE PACKAGE FORMAT
 
 The file starts with a master header, containing the following information:
 Signature (4 bytes) -> The "magic" signature "TPKG" (theme package)
 Version (1 byte) -> Version number, currently 1
 
 Entries Offset (8 bytes) -> The offset to the plist data containing information about file entries.
    Each file entry is a dictionary with the keys "filename"(nsstring), "offset"(nsnumber) and "length"(nsnumber)
 
 Start Offset (8 bytes) -> The offset where the file data starts (beginning of first file)
 Reserved (16 bytes) -> Reserved for future use
 */

#import <Foundation/Foundation.h>
#import "NSData+ZLib.h"
#import "ThemeFile.h"

void print_usage();

NSMutableData *_masterHeader;
NSMutableArray *_headerEntries;
NSMutableData *_fileData;
NSMutableData *_outputData;

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        if (argc < 3) {
            print_usage();
            return 0;
        }
        
        printf("%s -> %s\n", argv[1], argv[2]);
        
        _masterHeader = [[NSMutableData alloc] init];
        _outputData = [[NSMutableData alloc] init];
        _fileData = [[NSMutableData alloc] init];
        _headerEntries = [[NSMutableArray alloc] init];
        
        NSString *inputDirPath = [NSString stringWithUTF8String:argv[1]];
        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:inputDirPath];
        
        NSString *file;
        while (file = [dirEnum nextObject]) {
            NSString *filePath = [NSString pathWithComponents:@[inputDirPath,file]];
            NSLog(@"Writing %@", filePath);
            
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            
            NSDictionary *headerEntry = @{@"filename": file, @"offset": [NSNumber numberWithUnsignedInteger:[_fileData length]], @"length":[NSNumber numberWithUnsignedInteger:[fileData length]]};
            [_headerEntries addObject:headerEntry];
            
            [_fileData appendData:fileData];
        }
        
        NSData *headerEntriesData = [NSKeyedArchiver archivedDataWithRootObject:_headerEntries];
        
        // master header
        master_header_t mHeader;
        mHeader.signature[0] = 'T';
        mHeader.signature[1] = 'P';
        mHeader.signature[2] = 'K';
        mHeader.signature[3] = 'G';
        mHeader.entries_offset = sizeof(master_header_t);
        mHeader.start_offset = [headerEntriesData length]+sizeof(master_header_t);
        mHeader.version = 1;
        [_masterHeader appendBytes:&mHeader length:sizeof(mHeader)];
        
        // master header
        [_outputData appendData:_masterHeader];
        
        // nsarray header
        [_outputData appendData:headerEntriesData];
        
        // file contents
        [_outputData appendData:_fileData];
        
        NSLog(@"Compressing...");
        
        if ([[_outputData zlibDeflate] writeToFile:[NSString stringWithUTF8String:argv[2]] atomically:YES]) {
            NSLog(@"Success! Theme file written!");
        } else {
            NSLog(@"Error writing theme file!");
            return 1;
        }
    }
    
    return 0;
}

void print_usage()
{
    printf("Usage: packtheme directory outputfile\n");
}