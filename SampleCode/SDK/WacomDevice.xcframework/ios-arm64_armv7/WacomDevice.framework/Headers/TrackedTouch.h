/*!--------------------------------------------------------------------------------------------------

 FILE NAME

 TrackedTouch.h

 Abstract: Act as a container and manager for UITouches and perform touch rejection

 Version: 2.2.7

 COPYRIGHT
 Copyright WACOM Technology, Inc. 2012-2019
 All rights reserved.

 --------------------––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-––-----*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// This enumeration is used when setting handedness
typedef enum {eh_Unknown, eh_Right, eh_Left, eh_RightUpward, eh_RightDownward, eh_LeftUpward, eh_LeftDownward} ehandedness;

#pragma mark -
#pragma mark "TrackedTouch"
#pragma mark -

//! @class TrackedTouch
//! @abstract The purpose of TrackedTouch is to be a central class for correlating UITouches and location
//! data. The problem is that sometimes you can have a touch that while in the same location has a
//! different pointer. There can also be the case where there is the same pointer and slightly different
//! x and y. This class attempts to contain that knowledge
@interface TrackedTouch : NSObject

//! @property currentLocation
//! @abstract Provides the most current location of this touch point corresponding to the current touch
//! location of the contained UITouch. When this coordinate represents a stylus it has been modified to
//! improve stylus accuracy
@property (readonly) CGPoint currentLocation;

//! @property previousLocation
//! @abstract Provides the presious location of this touch point corresponding to the current touch
//! location of the contained UITouch. When this coordinate represents a stylus it has been modified to
//! improve stylus accuracy
@property (readonly) CGPoint previousLocation;

//! @property currentTouchLocation
//! @abstract Provides the most current location of this touch point. This point is the current touch
//! location contained in UITouch. This touch point does not have any stylus corrections applied.
@property (readonly) CGPoint currentTouchLocation;

//! @property previousTouchLocation
//! @abstract Provides the presious location of this touch point. This point is the previous touch
//! location contained in UITouch. This touch point does not have any stylus corrections applied.
@property (readonly) CGPoint previousTouchLocation;

//! @property associatedTouch
//! @abstract This property is used to provide easy access to the UITouch being tracked
@property (readonly) UITouch *associatedTouch;

//! @function isStylus
//! @returns returns whether or not this touch is the stylus touch
- (BOOL)isStylus;

//! @function isRejected
//! @returns returns whether or not this touch point has been rejection by the touch rejection
//! algorithms
- (BOOL)isRejected;

- (NSArray *)getCoalescedTrackedTouches;

@end

#pragma mark -
#pragma mark "TouchManager"
#pragma mark -

//! @class TouchManager
//! @abstract The purpose of TouchManager is to be the container for TrackedTouch'es such that you can
//! query it to see if a touch is in it adjust touches' locations. This is also the all important
//! keeper of the pen touch concept not to mention the touch rejection construct.
@interface TouchManager : NSObject

//! @property theStylusTouch
//! @abstract This property is used to provide easy access to the stylus' TrackedTouch Class. If the
//! pointer is null, then the stylus has not been identified yet.
@property (readonly) TrackedTouch *theStylusTouch;

//! @property touchRejectionEnabled
//! @abstract This property is used to enable or disable the touch rejection feature.
@property (readwrite) BOOL touchRejectionEnabled;

//! @property filteringEnabled
//! @abstract This property is used to enable or disable filtering of touch points.  Filtering is
//! applied to correct for inaccuracies with raw touch data.  Enabled by default.
//! Note: Not supported for iPhones
@property BOOL filteringEnabled;

//! Returns the singleton TouchManager
+ (TouchManager *)GetTouchManager;

//! @function count
//! @returns the number of TrackedTouches contained within the class.
- (NSUInteger)count;

//! @function addTouches
//! @returns nothing
//! @abstract takes the touches passes in to touchesBegan and adds them to an internal list for tracking
//! and use in touch rejection as well as stylus detection
- (void)addTouches:(NSSet *)touches_I view:(UIView *)view_I event:(UIEvent *)event_I;

//! @function moveTouches
//! @returns nothing
//! @abstract takes the touches passes in to touchesMoved and adds them if necessary to an internal list
//! for tracking, updates existing entries with the current and previous locations, and used in touch
//! rejection as well as stylus detection
- (void)moveTouches:(NSSet *)touches_I view:(UIView *)view_I event:(UIEvent *)event_I;

//! @function removeTouches
//! @returns nothing
//! @abstract takes the touches passes in to touchesEnded and removes them form the internal list of
//! TrackedTouches.
- (void)removeTouches:(NSSet *)touches_I view:(UIView *)view_I event:(UIEvent *)event_I;

//! @function getTouches
//! @returns returns the UITouch for the Stylus touchpoint if touch rejection is turned on. Otherwise,
//! it returns all of the UITouch points it knows about which will include the Stylus touchpoint as
//! well as other touches such as those by the palm or fingers.
- (NSArray *)getTouches;

//! @function getTrackedTouches
//! @returns returns the TrackedTouches for all touchpoints currently known about, which would include
//! the StylusTouchPoint if there is one..
- (NSArray *)getTrackedTouches;

//! @function clearTouches
//! @returns nothing
//! @abstract this is an important function that allows one to clear the TrackedTouch list. This should
//! only be used in cases where dead zones are being seen such as after a page turn or something of that
//! nature. Otherwise, it should not be used as it effectively erases the knowledge of currently
//! UITouches
- (void)clearTouches;

//! @function setHandedness
//! @param handedness the hand be used to draw.
//! @returns nothing
//! @abstract This function tells the SDK which hand the user is drawing with. Typically this is
//! autodetected (to eh_Right or eh_Left), but if touch rejection code is not being used, then this is a necessary step for
//! offset correction. If it is set by the SDK user the autodetection will not override it.
- (void)setHandedness:(ehandedness)handedness;

//! @function getHandedness
//! @returns the hand which the user uses to draw with.
//! @abstract This function returns the hand that is being used to draw, this can be provided by
//! the SDK user via the setHandedness call or automatically detected. If it is set by the SDK user
//! the autodetection will not override it. If you are not using the touch rejection code, please be sure
//! to set the handedness in the SDK.
- (ehandedness)getHandedness;

//! @function registerView
//! @returns nothing
//! @abstract this function registers the view with the touch manager. With the view registered
//! adding, moving, and remvoing touches is automatically handled.
- (void)registerView:(UIView*)view;

//! @function unregisterView
//! @returns nothing
//! @abstract this function unregisters the view with the touch manager
- (void)unregisterView;

//! @function adjustTouchpoint
//! @returns nothing
//! @abstract This function should never be used.
- (void)adjustTouchpoint:(CGPoint *)point touch:(UITouch*)touch_I view:(UIView *)view_I;

@end
