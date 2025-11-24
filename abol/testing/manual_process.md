so far, we have test-route.gpx
to run the test, run the app, then `debug -> simulate location -> test-route.gpx`
the notification should fire
then `debug -> simulate location -> start.gpx` to reset

## widget tests

### Verified
0. open app, start.gpx, enable alarm with note, lock screen, test-route.gpx, ensure alarm fires, open app, ensure alarm is disabled
1. open app, start.gpx, enable alarm with note, lock screen, open app, disable alarm, test-route.gpx, ensure alarm does not fire, open app, ensure alarm is disabled
2. open app, start.gpx, enable alarm with note, lock screen, test-route.gpx, ensure alarm fires, open app, start.gpx, arm alarm, close app, test-route.gpx, ensure alarm fires
3. ensure rectangular widget can be added to lock screen
4. open app, ensure alarm is disabled, lock screen, ensure widget shows disabled
5. open app, ensure alarm is enabled, lock screen, ensure widget shows enabled

### Unverified
6. open app, ensure alarm is disabled, lock screen, ensure clicking widget opens app and reminder text input keyboard, ensure alarm is still disabled
7. open app, ensure alarm is enabled, lock screen, ensure clicking widget disables alarm, open app, ensure that alarm is now disabled
(above are passing)
8. open app, start.gpx, enable alarm, lock screen, click widget to disable, test-route.gpx, ensure alarm does not fire, open app, ensure the app shows disarmed
    - this one almost passes but is whack, the location manager still monitors the region even when the widget disables the alarm.
9. open app, start.gpx, enable alarm, lock screen, test-route.gpx, ensure alarm fires, ensure widget switches from enabled to disabled
    - somehow the alarm didn't even fire, likely due to no reset of `exitEventTriggered`
### when killed...
10. open app, start.gpx, arm alarm, kill app, test-route.gpx, see alarm fires, open app, see alarm is disabled
11. open app, start.gpx, arm alarm, kill app, disarm via widget, test-route.gpx, see alarm does not fire, open app, ensure alarm is disabled
