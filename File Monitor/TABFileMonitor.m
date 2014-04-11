//
//  TABFileMonitor.m
//  File Monitor
//
//  Created by Travis Blankenship on 3/27/14.
//  Copyright (c) 2014 Travis Blankenship. All rights reserved.
//

#import "TABFileMonitor.h"

@interface TABFileMonitor ()
{
@private
    
    NSURL *_fileURL;
    dispatch_source_t _source;
    int _fileDescriptor;
    BOOL _keepMonitoringFile;
}

@end

@implementation TABFileMonitor

- (id)initWithURL:(NSURL *)URL
{
    self = [self init];
    if (self)
    {
        _fileURL = URL;
        _keepMonitoringFile = NO;
        [self __beginMonitoringFile];
    }
    return self;
}

- (void)dealloc
{
    dispatch_source_cancel(_source);
}

- (void)__beginMonitoringFile
{
    // Add a file descriptor for our test file
    _fileDescriptor = open([[_fileURL path] fileSystemRepresentation],
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
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeMetadata];
            });
        }
        if (eventType & DISPATCH_VNODE_DELETE)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeDeleted];
                [self __recreateDispatchSource];
            });
        }
        if (eventType & DISPATCH_VNODE_EXTEND)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeSize];
            });
        }
        if (eventType & DISPATCH_VNODE_LINK)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeObjectLink];
            });
        }
        if (eventType & DISPATCH_VNODE_RENAME)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeRenamed];
                [self __recreateDispatchSource];
            });
        }
        if (eventType & DISPATCH_VNODE_REVOKE)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeRevoked];
            });
        }
        if (eventType & DISPATCH_VNODE_WRITE)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self.delegate fileMonitor:self
                              didSeeChange:TABFileMonitorChangeTypeModified];
            });
        }
    });
    
    dispatch_source_set_cancel_handler(_source, ^
    {
        close(_fileDescriptor);
        _fileDescriptor = 0;
        _source = nil;
        
        // If this dispatch source was canceled because of a rename or delete notification, recreate it
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

@end
