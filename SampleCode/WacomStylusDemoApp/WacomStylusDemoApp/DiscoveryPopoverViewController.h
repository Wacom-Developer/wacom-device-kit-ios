///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	header file for the discovery popover controller
//
// COPYRIGHT
//    Copyright (c) 2012 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <WacomDevice/WacomDeviceFramework.h>
@interface DiscoveryPopoverViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
		IBOutlet UIView *popoverview;
}
/// adds a device to the table in the popover
-(void) addDevice:(WacomDevice *)device_I;

/// removes a device from the table in the popover
-(void) removeDevice:(WacomDevice *)device_I;

/// adds a device int the discovery popover if it is not there already
-(void)updateDevices:(WacomDevice *)device_I;
@end
