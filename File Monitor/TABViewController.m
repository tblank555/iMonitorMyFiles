//
//  TABViewController.m
//  File Monitor
//
//  Created by T Blank on 3/25/14.
//  Copyright (c) 2014 T Blank. All rights reserved.
//

#import "TABViewController.h"

@interface TABViewController ()
{
    __weak IBOutlet UITextField *_textToWriteField;
}

@end

@implementation TABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self __writeTextToDisk:@"Whadderp?"];
}

- (IBAction)write:(UIButton *)sender
{
    [self __writeTextToDisk:_textToWriteField.text];
}

- (void)__writeTextToDisk:(NSString *)text
{
    NSData *dataFromText = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] firstObject];
    [dataFromText writeToURL:[documentsDirectory URLByAppendingPathComponent:@"testFile"]
                     options:kNilOptions
                       error:nil];
}

@end
