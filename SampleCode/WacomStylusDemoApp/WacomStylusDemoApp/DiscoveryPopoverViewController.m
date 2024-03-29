///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	implementation file for the discovery popover controller
//
// COPYRIGHT
//    Copyright (c) 2012 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "DiscoveryPopoverViewController.h"

@interface DiscoveryPopoverViewController ()

@end

@implementation DiscoveryPopoverViewController
{
	NSMutableArray * mDevices;
	UITableView * mDiscoveryTable;
}

////////////////////////////////////////////////////////////////////////////////

/// initializes the class with a nib, but mainly initializes the mDevices variable.

- (id) initWithNibName:(NSString *)nibNameOrNil_I bundle:(NSBundle *)nibBundleOrNil_I
{
	self = [super initWithNibName:nibNameOrNil_I bundle:nibBundleOrNil_I];
	if (self)
	{
		mDevices = nil;
		// Custom initialization
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////

/// notification method once the view has loaded used to initialize and update the
/// discovery table.

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(100.0, 0.0, 80.0, 39.0);
	[button setTitle:@"Done" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonPushed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 39.0, 280.0, 1.0)];
	separator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
	[self.view addSubview:separator];
	
	if (mDiscoveryTable == nil)
	{
		CGRect discoveryTableFrame = CGRectMake(0.0, 40.0, 280.0, 280.0);
		mDiscoveryTable = [[UITableView alloc] initWithFrame:discoveryTableFrame style:UITableViewStylePlain];
		[mDiscoveryTable setDataSource:self];
		[mDiscoveryTable setDelegate:self];
		mDiscoveryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	[self.view addSubview:mDiscoveryTable];
	[mDiscoveryTable setEditing:NO];
	[mDiscoveryTable setBounces:NO];
}

////////////////////////////////////////////////////////////////////////////////

- (void) buttonPushed
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////

/// notification method used to get a list of the devices detected by the Wacom SDK and put them
/// into the table.

- (void) viewWillAppear:(BOOL)animated_I
{
	mDevices = [[[WacomManager getManager] getDevices] mutableCopy];
	if ([mDevices count] == 0)
		[mDiscoveryTable setRowHeight:320.0];
	else
		[mDiscoveryTable setRowHeight:50.0];

	[self updateTable];
	[super viewWillAppear:animated_I];
}

////////////////////////////////////////////////////////////////////////////////

/// notification method used to stop device discovery and clear our the device list.

- (void) viewDidDisappear:(BOOL)animated_I
{
	[[WacomManager getManager] stopDeviceDiscovery];
	mDevices = nil;
	[super viewDidDisappear:animated_I];
}

////////////////////////////////////////////////////////////////////////////////

/// table data source delegate method to tell how many columns are in the table
/// there is only one.

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView_I
{
	return 1;
}

////////////////////////////////////////////////////////////////////////////////

// table data source method to retreive the contents of a specific cell.

- (void) tableView:(UITableView *)tableView_I didSelectRowAtIndexPath:(NSIndexPath *)indexPath_I
{
	if (mDevices.count != 0)
	{
		WacomDevice * selectedDevice = mDevices[[indexPath_I indexAtPosition:1]];
		if ([selectedDevice isCurrentlyConnected])
		{
			[[WacomManager getManager] deselectDevice:selectedDevice];
			[mDevices removeObjectAtIndex:[indexPath_I indexAtPosition:1]];
		}
		else
		[[WacomManager getManager] selectDevice:selectedDevice];
	}
}

////////////////////////////////////////////////////////////////////////////////

// table data source method to retreive the contents of a specific cell.

- (NSInteger) tableView:(UITableView *)tableView_I numberOfRowsInSection:(NSInteger)section_I
{
	if (mDevices.count == 0)
	{
		[mDiscoveryTable setRowHeight:320.0];
		return 1; // Our Help message.
	}
	else
	{
		[mDiscoveryTable setRowHeight:50.0];
		return mDevices.count;
	}
}

////////////////////////////////////////////////////////////////////////////////

// table data source method to retreive the contents of a specific cell.

- (UITableViewCell *) tableView:(UITableView *)tableView_I cellForRowAtIndexPath:(NSIndexPath *)indexPath_I
{
	UITableViewCell * cell = [[UITableViewCell alloc] init];

	if (mDevices.count == 0)
	{
		[[cell textLabel] setLineBreakMode:NSLineBreakByWordWrapping];
		[[cell textLabel] setText:@"Please set your device to pairing mode..."];
		cell.textLabel.numberOfLines= 0;
	}
	else
	{
		WacomDevice * selectedDevice = mDevices[[indexPath_I indexAtPosition:1]];
		[[cell textLabel] setText:[selectedDevice getName]];
		if ([selectedDevice isCurrentlyConnected] == YES)
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		}
	}
	return cell;
}

////////////////////////////////////////////////////////////////////////////////

// method for updating the contents of the table view when requested

- (void) updateTable
{
	[mDiscoveryTable reloadData];
	[self.view setNeedsDisplay];

}

////////////////////////////////////////////////////////////////////////////////

// a method for adding devices to the internal device list if it is not already there.

- (void) addDeviceToList:(WacomDevice *)device_I
{
	//if the device list has not been allocated return
	if (mDevices == nil)
	{
		return;
	}
	//if we are not in discovery mode return
	if (![[WacomManager getManager] isDiscoveryInProgress])
	{
		return;
	}
	//if we already have the device in our list return
	for (WacomDevice * listDevice in mDevices)
	{
		if ([device_I getPeripheral] == [listDevice getPeripheral])
		{
			return;
		}
	}

	//add the device to our internal list
	[mDevices addObject:device_I];
}

////////////////////////////////////////////////////////////////////////////////

// a method for adding a device to the device list, then invoking on the main thread
// to have the UI update.

- (void) addDevice:(WacomDevice *)device_I
{
	[self addDeviceToList:device_I];
	[self performSelectorOnMainThread:@selector(updateTable)
								  withObject:nil
							  waitUntilDone:YES];

}

////////////////////////////////////////////////////////////////////////////////

/// a method for removing a device to the device list if it exists

- (void) removeDeviceFromList:(WacomDevice *)device_I
{

	// if the device list has been allocated
	if (mDevices == nil)
	{
		return;
	}
	//if the device is in the list remove it.
	for (WacomDevice * listedDevice in mDevices )
	{
		if ([listedDevice getPeripheral] == [device_I getPeripheral])
		{
			[mDevices removeObject:listedDevice];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////

/// a method for removing a device from the device list, then invoking on the main thread
/// to have the UI update.

- (void) removeDevice:(WacomDevice *)device_I
{
	[self removeDeviceFromList:device_I];
	[self performSelectorOnMainThread:@selector(updateTable)
								  withObject:nil
							  waitUntilDone:YES];
}

////////////////////////////////////////////////////////////////////////////////

/// add the device to the list if it is not already in it, then forces an update of
/// the devices table in the UI by calling the update method on the main thread.

- (void) updateDevices:(WacomDevice *)device_I
{
	[self addDeviceToList:device_I];
	[self performSelectorOnMainThread:@selector(updateTable)
								  withObject:nil
							  waitUntilDone:YES];
}

////////////////////////////////////////////////////////////////////////////////

/// notification method for when there is a low memory situation.

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
