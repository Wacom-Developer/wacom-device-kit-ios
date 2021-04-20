///////////////////////////////////////////////////////////////////////////////
//
// COPYRIGHT
//    Copyright (c) 2014 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <WacomDevice/WacomDeviceFramework.h>

@interface HandPositionTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	IBOutlet UIView *handPositionPopoverView;
}

@end
