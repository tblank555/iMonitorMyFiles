//
//  TABViewController.m
//  File Monitor
//
//  Created by Travis Blankenship on 3/25/14.
//  Copyright (c) 2014 Travis Blankenship. All rights reserved.
//

#import "TABViewController.h"

#import <iMonitorMyFiles/TABFileMonitor.h>

@interface TABViewController () <TABFileMonitorDelegate, UITextFieldDelegate>
{
    NSURL *_testFileURL;
    __weak IBOutlet UITextField *_textToWriteField;
    __weak IBOutlet UITextView *_eventTextView;
}

@end

@implementation TABViewController

#pragma mark - View Lifecycle

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
    
    TABFileMonitor *fileMonitor = [[TABFileMonitor alloc] initWithURL:_testFileURL];
    fileMonitor.delegate = self;
}

#pragma mark - TABFileMonitorDelegate

- (void)fileMonitor:(TABFileMonitor *)fileMonitor didSeeChange:(TABFileMonitorChangeType)changeType
{
    if (changeType == TABFileMonitorChangeTypeMetadata)
    {
        [self __logTextToScreen:@"Test file's metadata changed."];
    }
    else if (changeType == TABFileMonitorChangeTypeDeleted)
    {
        [self __logTextToScreen:@"Test file was deleted."];
    }
    else if (changeType == TABFileMonitorChangeTypeSize)
    {
        [self __logTextToScreen:@"Test file changed size."];
    }
    else if (changeType == TABFileMonitorChangeTypeObjectLink)
    {
        [self __logTextToScreen:@"Test file's object link count changed."];
    }
    else if (changeType == TABFileMonitorChangeTypeRenamed)
    {
        [self __logTextToScreen:@"Test file was renamed."];
    }
    else if (changeType == TABFileMonitorChangeTypeRevoked)
    {
        [self __logTextToScreen:@"Test file was revoked."];
    }
    else if (changeType == TABFileMonitorChangeTypeModified)
    {
        [self __logTextToScreen:@"Test file was modified."];
    }
}

#pragma mark - Actions

- (IBAction)write:(UIButton *)sender
{
    [self __writeText:_textToWriteField.text
                toURL:_testFileURL];
    [self dismissKeyboard:sender];
}

- (IBAction)dismissKeyboard:(UIButton *)sender
{
    [_textToWriteField resignFirstResponder];
}

#pragma mark - UI Helper Methods

- (void)__writeText:(NSString *)text toURL:(NSURL *)URL
{
    [self __logTextToScreen:[NSString stringWithFormat:@"Writing text: %@", text]];
    
    NSData *dataFromText = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    [dataFromText writeToURL:URL
                     options:kNilOptions
                       error:nil];
}

- (void)__logTextToScreen:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        NSString *logTime = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *previousText = _eventTextView.text;
        _eventTextView.text = [NSString stringWithFormat:@"%@: %@\n%@", logTime, text, previousText];
    });
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self write:nil];
    return YES;
}

@end
