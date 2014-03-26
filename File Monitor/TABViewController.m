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
    dispatch_source_t _source;
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
    
    // Add a file descriptor for our test file
    int fileDescriptor = open([[_testFileURL path] fileSystemRepresentation],
                              O_EVTONLY);
    
    // Create a GCD queue to receive file change event notifications on
    dispatch_queue_t eventQueue = dispatch_queue_create("Filesystem Event Queue", 0);
    
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                     fileDescriptor,
                                     DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_DELETE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE | DISPATCH_VNODE_WRITE,
                                     eventQueue);
    
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
            [self __logTextToScreen:@"Test file was renamed."];
        if (eventType & DISPATCH_VNODE_REVOKE)
            [self __logTextToScreen:@"Test file was revoked."];
        if (eventType & DISPATCH_VNODE_WRITE)
            [self __logTextToScreen:@"Test file was modified."];
        [self __logTextToScreen:@"---------------------------"];
    });
    
    dispatch_source_set_cancel_handler(_source, ^
    {
        close(fileDescriptor);
    });
    
    // Start monitoring the test file
    dispatch_resume(_source);
}

- (void)dealloc
{
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

#pragma mark - Helper Methods

- (void)__writeText:(NSString *)text toURL:(NSURL *)URL
{
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

@end
