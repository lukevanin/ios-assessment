# Hornet Technical Assessment
Luke Van In


## Question 1: Background layout-related crashes

> Right after rushed iOS13 update we started experiencing background related crashes. Call
stacks in Crashlytics/Firebase were not helpful (see below). We observed
UIApplicationDidEnterBackground notifications as a last thing in the breadcrumb log.
What would you do to track and address/fix this issue?

I would first try to reproduce the crash on the my local development environment. I would start
by setting breakpoints near the region of code indicated by the crash report, namely 
`application:applicationDidEnterBackground:`. I would also search the codebase for 
any code that subscribes to the `UIApplicationDidEnterBackground` notification. 

In case the the bug is not consistently reproducible, I would examine the code and look for 
likely causes of the error. The crash log seems to hint that the UI was updated from a thread
other than the main thread, after the application entered the background. This seems to hint 
that a background task was started while the app was active, or just before entering the 
background.

I would specifically look for calls to 
`beginBackgroundTask(withName:expirationHandler:)` which is used to extend the 
background lifetime of an app, and also `URLSession.background(withIdentifier:)` 
which is used to execute URL downloads in the separate background process. While neither
of these directly cause crashes, it's likely that a UI layout is being triggered as a result of work
being done on one of these methods.

A common cause of bugs is updating the UI from a background thread, instead
of from the main thread. I would specifically check for code creating a background task, and 
ensure that any UI updates are called from the main thread. I would also enable the `Main 
Thread Checker` in Xcode, to check for errors at runtime.

Solutions to common problems:
* Crash is caused by a UI update on a background thread: Wrap the UI code in a call to 
`DispatchQueue.main.async` (making sure to pass self as a weak reference).
* Crash is caused by a callback in a background process: Disable UI updates when the app 
enters the background.

## Question 2: Background crash (iOS13 only)

> We started seeing this crash after the iOS13 update. It originated from in-app purchase
stack ( StoreKit ’s SKPropductRequestDelegate productRequest:didReceiveResponse: ) and
ends in our legacy network stack ( AFNetworking -based, we use it only for last couple of
requests).
>
> It crashes on following line in our HTTPSession.m file:
NSAssert([[NSThread currentThread] isMainThread], @“This method must be called
on the main thread.”)
>
> This assert is there for historical reasons and we do not want to remove it.
>
> What is the cause of this crash and how would you fix that?

My initial guess is similar to the causes in the previous question, where the code is being
called on a background thread.

The documentation for [SKPropductRequestDelegate](https://developer.apple.com/documentation/storekit/skproductsrequestdelegate)
seems to confirm this:

> Warning
>
> Responses received by the SKProductsRequestDelegate may not be returned on a specific 
thread. If you make assumptions about which queue will handle delegate responses, you may 
encounter unintended performance and compatibility issues in the future.

A simple solution might be to wrap the the code in a call to `DispatchQueue.main.async` to
ensure that it is called on the main thread.

## Question 3: Coding excercise

Please see the implementation in the `ComponentKit` framework for the implementation 
details. Run the application to see a working example. 

Notes:

* `BrowserViewController` delegates instantiation of the child view controller to a data 
source, which allows it to display any content that is contained in a view controller (in theory). I
only tested this with the scrollable stack view. I suspect there may be some complications 
when used with a container such as a navigation controller or tab controller.
* I only tested this code on an iPhoneX with iOS12. It should be generally applicable to iPhone
running iOS12 and above. 
* This won't work on iOS11 or below, due to the use of safe area insets.
* The browser controller does not support landscape mode. My code uses the built-in 
pagination on `UIScrollView`, which doesn't work well with the insets in landscape mode. It
is possible to support this using a custom `UICollectionViewLayout`, and overriding the
target content offset for proposed content offset method.
* For a production application, I would not use  `UIStackView` for scrolling a very long list 
of content, and rather use a `UICollectionView` or `UITableView` instead.
* I spent minimal time on the appearance of UI itself. The UI is very basic as a result. I could
have spent more time making it look prettier.

## Question 4: Architecture

> As part of the Hornet Health initiative we allow users to set their KYS (Know Your Status)
status.
>
> Example: HIV-negative, last check: November 2019.
>
>Every time user has outdated (older than X months) status we display a post-launch
prompt to update their KYS. First we display prompt to the user “Your KYS is outdated,
would you like to update…” allowing user to either postpone the update or update his
status right away. We update the status itself via dedicated modal screen with cancel / save
buttons.
>
> On cancel we dismiss the screen. On save we dismiss the screen too and update users’s
profile KYS using an API call.
>
>How would you use to design this process in an iOS app?

This problem looks like a perfect fit for a classic finite state machine (FSM).

1. The states are well defined.
2. There are a finite number of states.
3. The transitions between states are well defined.
4. The entry and exit points are wel defined.

The FSM can be implemented as a pure code model, indepentently of any UI code, enabling 
the model to be tested easily with basic unit tests. The business logic is cleanly encapsulated 
within the model, which allows the UI code to stay focused on presentation. The separation
also allows busines logic and UI to evolve independently of each other. 

The procedure for converting the requirements into code:

1. See which states need to be represented in code. These will be implemented as individual 
states in the FSM. The states seem to be:
* Check user's status. Returns up to date, or not up to date.
* Prompt the user to update their status. User can continue or cancel.
* Allow the user to update their status. User can save or cancel.
* Save the user's status. Returns success or faiilure.
* Finalised. 

2. See which actions need to be performed. These will be implemented as public methods on
the FSM:
* Check: Begin the KYS process.
* Update: Continue to update the user's profile
* Cancel: Cancel the prompt or in-progress update
* Save: Save the new status.

3. Determine how the status information is going to be fetched and saved. This would be 
dependant on the backend API if one exists, or the design of the backend API might need to
be specified at this point. For this example I assumed the following status:
```
enum KYSStatus {
  case positive
  case nagative
}
```
I also assumed a hypothetical web service that would return the existing status, and where it 
was up to date or not, e.g.
```
struct KYSProfile {
  let status: KYSStatus?
  let needsUpdate: Bool
}
```
A real world API would likely be a lot more complicated, and have more fields and conditions.

3. With the above, we can define the abstract interfaces for the state machine. The state 
machine needs a way to transition between states. It also needs to provide methods for 
checking and saving the status.
 e.g.
```
protocol IStateContext {
 func gotoCheckState()
 func gotoPromptState()
 func gotoUpdateState()
 func gotoSaveState()
 func gotoFinalState()
 func getStatus(completion: () - Void)
}
```

4. The abstract interface can also be defined. I find it useful to define `enter` and `exit` 
methods on states, which are called when transitioning between states. The states also need
to implement the supported action methods. e.g.
```
protocol IState {
  func check() 
  func update() 
  func cancel()
  func save(status: KYSStatus)
}
```

5. Once the interfaces have been defined, all that remains is the actual implementation of the
state machine and individual state classes (the rest of the owl). See the `Model` project target
for an example implementation, and `ModelTests` for unit tests which test the model. 

I have not included a UI implementation for this exercise, however I have described the 
behaviour that the UI should implement when using the model. 

