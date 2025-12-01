so far, we have test-route.gpx
to run the test, run the app, then `debug -> simulate location -> test-route.gpx`
the notification should fire
then `debug -> simulate location -> start.gpx` to reset

## widget tests

### Verified (as of git commit 643018ab981bc28b11211a60f7b5f15fae798a34)
0. open app, start.gpx, enable alarm with note, lock screen, test-route.gpx, ensure alarm fires, open app, ensure alarm is disabled
1. open app, start.gpx, enable alarm with note, lock screen, open app, disable alarm, test-route.gpx, ensure alarm does not fire, open app, ensure alarm is disabled
2. open app, start.gpx, enable alarm with note, lock screen, test-route.gpx, ensure alarm fires, open app, start.gpx, arm alarm, close app, test-route.gpx, ensure alarm fires
3. ensure rectangular widget can be added to lock screen
4. open app, ensure alarm is disabled, lock screen, ensure widget shows disabled
5. open app, ensure alarm is enabled, lock screen, ensure widget shows enabled
6. open app, ensure alarm is disabled, lock screen, ensure clicking widget opens app and reminder text input keyboard, ensure alarm is still disabled
7. open app, ensure alarm is enabled, lock screen, ensure clicking widget disables alarm, open app, ensure that alarm is now disabled
8. open app, start.gpx, enable alarm, lock screen, click widget, open app, ensure alarm is disabled, test-route.gpx, ensure that alarm does not fire, open app, ensure the app shows disarmed
9. open app, start.gpx, enable alarm, lock screen, test-route.gpx, ensure alarm fires, ensure widget switches from enabled to disabled
10. restart app (critical due to debugger location spoofing not working), open app, arm alarm, kill app, walk away, ensure alarm fires and has correct msg, open app, see alarm is disabled
11. restart app (critical due to debugger location spoofing not working), open app, arm alarm, kill app, disable via widget, walk away, see alarm does not fires, open app, see alarm is disabled

### Unverified
