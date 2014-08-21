# aerogear-ios-http
Thin layer to take care of your http requests working with NSURLSession. 
Taking care of: 

* Json serializer,
* Multipart upload, 
* Pluggable object serialization.

100% Swift.

## Example Usage

```swift
var http = AGSessionImpl(url: "http://server.com", sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())

http.GET(nil, success: {(response: AnyObject?) in
	if (response != nil) {
		// do something 
	}
}, failure: {(error: NSError) in
	// log error
})
```
## Running tests

The project uses [aerogear-ios-httpstub](https://github.com/aerogear/aerogear-ios-httpstub) framework for stubbing its http network requests. Before running the tests, ensure that a copy is added in your project using `git submodule`. On the root directory of the project run:

```bash
git submodule init && git submodule update
```

You are now ready to run the tests.

## Adding the library to your project 

Follow these steps to add the library in your Swift project.

1. [Clone this repository](#1-clone-this-repository)
2. [Add `AeroGearHttp.xcodeproj` to your application target](#2-add-aerogearhttp-xcodeproj-to-your-application-target)
3. Start writing your app!

> **NOTE:** Hopefully in the future and as the Swift language and tools around it mature, more straightforward distribution mechanisms will be employed using e.g [cocoapods](http://cocoapods.org) and framework builds. Currently neither cocoapods nor binary framework builds support Swift. For more information, consult this [mail thread](http://aerogear-dev.1069024.n5.nabble.com/aerogear-dev-Swift-Frameworks-Static-libs-and-Cocoapods-td8456.html) that describes the current situation.

### 1. Clone this repository

```
git clone git@github.com:aerogear/aerogear-ios-http.git
```

### 2. Add `AeroGearHttp.xcodeproj` to your application target

Right-click on the group containing your application target and select `Add Files To YourApp`
Next, select `AeroGearHttp.xcodeproj`, which you downloaded in step 1.

### 3. Start writing your app!

If you run into any problems, please [file an issue](http://issues.jboss.org/browse/AEROGEAR) and/or ask our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users). You can also join our [dev mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev).  

