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
    NSURL *_testFileURL;
    __weak IBOutlet UITextField *_textToWriteField;
}

@end

@implementation TABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the test file URL
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] firstObject];
    _testFileURL = [documentsDirectory URLByAppendingPathComponent:@"testFile"];
    
    // Write some text to that test file
    [self __writeText:@"Whadderp?"
                toURL:_testFileURL];
    
    // Add a file descriptor for our test file
    CFFileDescriptorRef fileDescriptor = open([[_testFileURL path] fileSystemRepresentation], O_EVTONLY);
    
    // Create a GCD queue to receive file change event notifications on
    dispatch_queue_t eventMonitorQueue = dispatch_queue_create("Event Monitor Queue", 0);
}

- (IBAction)write:(UIButton *)sender
{
    [self __writeText:_textToWriteField.text
                toURL:_testFileURL];
}

- (void)__writeText:(NSString *)text toURL:(NSURL *)URL
{
    NSData *dataFromText = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    [dataFromText writeToURL:URL
                     options:kNilOptions
                       error:nil];
}

@end
