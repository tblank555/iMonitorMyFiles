//
//  TABViewController.m
//  File Monitor
//
//  Created by T Blank on 3/25/14.
//  Copyright (c) 2014 T Blank. All rights reserved.
//

#import "TABViewController.h"

@interface TABViewController ()

@end

@implementation TABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self __writeTestFile];
}

- (void)__writeTestFile
{
    NSString *testString = @"Whadderp?";
    NSData *dataFromText = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] firstObject];
    [dataFromText writeToURL:[documentsDirectory URLByAppendingPathComponent:@"testFile"]
                     options:kNilOptions
                       error:nil];
}

@end
