so far, we have test-route.gpx
to run the test, run the app, then `debug -> simulate location -> test-route.gpx`
the notification should fire
then `debug -> simulate location -> start.gpx` to reset

## widget tests
1. ensure rectangular widget can be added to lock screen
2. open app, ensure alarm is disabled, lock screen, ensure widget shows disabled
3. open app, ensure alarm is enabled, lock screen, ensure widget shows enabled
4. open app, ensure alarm is disabled, lock screen, ensure clicking widget opens app and reminder text input keyboard
5. open app, ensure alarm is enabled, lock screen, ensure clicking widget disables alarm
(above are passing)
6. open app, start.gpx, enable alarm, lock screen, click widget to disable, test-route.gpx, ensure alarm does not fire, open app, ensure the app shows disarmed
    - this one almost passes but is whack, the location manager still monitors the region even when the widget disables the alarm.
7. open app, start.gpx, enable alarm, lock screen, test-route.gpx, ensure alarm fires, ensure widget switches from enabled to disabled
    - somehow the alarm didn't even fire, likely due to no reset of `exitEventTriggered`
