//
//  Tweak.m
//  Tweak
//
//  Created by Alexandra Aurora Göttlicher
//

#import "Tweak.h"
#import <substrate.h>
#import "../Preferences/PreferenceKeys.h"
#import "../Preferences/NotificationKeys.h"

#pragma mark - ExampleClass class hooks

/**
 * Example hook.
 */
static void (* orig_ExampleClass_exampleMethod)(ExampleClass* self, SEL _cmd);
static void override_ExampleClass_exampleMethod(ExampleClass* self, SEL _cmd) {
	orig_ExampleClass_exampleMethod(self, _cmd);
}

#pragma mark - Preferences

/**
 * Loads the user's preferences.
 */
static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue)
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
}

#pragma mark - Constructor

/**
 * Initializes the Tweak.
 *
 * First it loads the preferences and continues if Tweak is enabled.
 * Secondly it sets up the hooks.
 * Finally it registers the notification callbacks.
 */
__attribute((constructor)) static void initialize() {
	load_preferences();

    if (!pfEnabled) {
        return;
    }

	MSHookMessageEx(objc_getClass("ExampleClass"), @selector(exampleMethod), (IMP)&override_ExampleClass_exampleMethod, (IMP *)&orig_ExampleClass_exampleMethod);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
