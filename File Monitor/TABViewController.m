//
//  TABViewController.m
//  File Monitor
//
//  Created by Travis Blankenship on 3/25/14.
//  Copyright (c) 2014 Travis Blankenship. All rights reserved.
//

#import "TABViewController.h"

@interface TABViewController () <UITextFieldDelegate>
{
    NSURL *_testFileURL;
    dispatch_source_t _source;
    int _fileDescriptor;
    BOOL _keepMonitoringFile;
    __weak IBOutlet UITextField *_textToWriteField;
    __weak IBOutlet UITextView *_eventTextView;
}

@end

@implementation TABViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Reset this flag. It allows us to keep monitoring a file even if another app deletes and recreates it
    _keepMonitoringFile = NO;
    
    // Create the test file URL
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] firstObject];
    _testFileURL = [documentsDirectory URLByAppendingPathComponent:@"testFile"];
    
    // Write some text to that test file
    [self __writeText:@"Whadderp?"
                toURL:_testFileURL];
    
    [self __beginMonitoringFile];
}

- (void)dealloc
{
    dispatch_source_cancel(_source);
}

#pragma mark - Private Methods

- (void)__beginMonitoringFile
{
    // Add a file descriptor for our test file
    _fileDescriptor = open([[_testFileURL path] fileSystemRepresentation],
                           O_EVTONLY);
    
    // Get a reference to the default queue so our file notifications can go out on it
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Create a dispatch source
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                     _fileDescriptor,
                                     DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_DELETE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE | DISPATCH_VNODE_WRITE,
                                     defaultQueue);
    
    // Log one or more messages to the screen when there's a file change event
    dispatch_source_set_event_handler(_source, ^
    {
        unsigned long eventType = dispatch_source_get_data(_source);
        if (eventType & DISPATCH_VNODE_ATTRIB)
            [self __logTextToScreen:@"Test file's metadata changed."];
        if (eventType & DISPATCH_VNODE_DELETE)
            [self __logTextToScreen:@"Test file was deleted."];
        if (eventType & DISPATCH_VNODE_EXTEND)
            [self __logTextToScreen:@"Test file changed size."];
        if (eventType & DISPATCH_VNODE_LINK)
            [self __logTextToScreen:@"Test file's object link count changed."];
        if (eventType & DISPATCH_VNODE_RENAME)
        {
            [self __logTextToScreen:@"Test file was renamed."];
            [self __recreateDispatchSource];
        }
        if (eventType & DISPATCH_VNODE_REVOKE)
            [self __logTextToScreen:@"Test file was revoked."];
        if (eventType & DISPATCH_VNODE_WRITE)
            [self __logTextToScreen:@"Test file was modified."];
        [self __logTextToScreen:@"---------------------------"];
    });
    
    dispatch_source_set_cancel_handler(_source, ^
    {
        close(_fileDescriptor);
        _fileDescriptor = 0;
        _source = nil;
        
        // If this dispatch source was canceled because of a rename notification, recreate it
        if (_keepMonitoringFile)
        {
            _keepMonitoringFile = NO;
            [self __beginMonitoringFile];
        }
    });
    
    // Start monitoring the test file
    dispatch_resume(_source);
}

- (void)__recreateDispatchSource
{
    _keepMonitoringFile = YES;
    dispatch_source_cancel(_source);
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
