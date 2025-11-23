had issues with chat gpt's instructions, starting from another source

https://blog.logrocket.com/building-ios-lock-screen-widgets/?utm_source=chatgpt.com

notes:
* It seems like I will want a `accessoryCircular`

what does it look like?
circle with "ABOL" on top, and [enabled|disabled] below it

...

ok, so revising after getting most of the widget to show
i had to work through the state since the widget manages state in a different memory space
this leads to the app having to check the state of the alarm upon "waking up"

not too bad, but anyways, it exposed some weirdness in the code. I now plan to sort that out and close the
final "hole". The final hole is when the user disables the alarm via the widget, and does not open the app
before leaving the area. In this case, the handler will fire (`didExitRegion`). So, in this function, we
need to fetch the SharedDefaults value. If this is `disarmed` (as opposed to what is expected which is
`armed`), then we will simply do the clean up then. The clean up is also done in the `AlarmManager` via
`checkForExternalChanges`.

UNLESS `checkForExternalChanges` is called even when the region did exit thing happens (instead of user opening app)
* lets check this, and general control flow
