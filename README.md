# aerogear-ios-http  [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-http.png)](https://travis-ci.org/aerogear/aerogear-ios-http)
Thin layer to take care of your http requests working with NSURLSession. 
Taking care of: 

* Json serializer
* Multipart upload 
* HTTP Basic/Digest authentication support
* Pluggable object serialization
* background processing support

100% Swift.

## Example Usage

To perform an HTTP request use the convenient methods found in the Http object. Here is an example usage:

```swift
let http = Http(baseURL: "http://server.com")

http.GET("/get", completionHandler: {(response, error) in
     // handle response
})

http.POST("/post",  parameters: ["key": "value"], completionHandler: {(response, error) in
     // handle response
})
...


```

### Authentication

The library also leverages the build-in foundation support for http/digest authentication and exposes a convenient interface by allowing the credential object to be passed on the request. Here is an example:

> **NOTE:**  It is advised that HTTPS should be used when performing authentication of this type

```swift
let credential = NSURLCredential(user: "john", password: "pass", persistence: .None)

http.GET("/protected/endpoint", credential: credential, completionHandler: {(response, error) in
   // handle response
})
```

 You can also set a credential per protection space, so it's automatically picked up once http challenge is requested by the server, thus omitting the need to pass the credential on each request. In this case, you must initialize the ```Http``` object with a custom session configuration object, that has its credentials storage initialized with your credentials:

 ```swift
// create a protection space
var protectionSpace: NSURLProtectionSpace = NSURLProtectionSpace(host: "httpbin.org", port: 443,`protocol`: NSURLProtectionSpaceHTTPS, realm: "me@kennethreitz.com", authenticationMethod: NSURLAuthenticationMethodHTTPDigest);

// setup credential
// notice that we use '.ForSession' type otherwise credential storage will discard and
// won't save it when doing 'credentialStorage.setDefaultCredential' later on
let credential = NSURLCredential(user: user, password: password, persistence: .ForSession)

// assign it to credential storage
var credentialStorage: NSURLCredentialStorage = NSURLCredentialStorage.sharedCredentialStorage()
credentialStorage.setDefaultCredential(credential, forProtectionSpace: protectionSpace);

// set up default configuration and assign credential storage
var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
configuration.URLCredentialStorage = credentialStorage

// assign custom configuration to Http
var http = Http(baseURL: "http://httpbin.org", sessionConfig: configuration)

http.GET("/protected/endpoint", completionHandler: {(response, error) in
   // handle response
})
```

### OAuth2 Protocol Support

To support the OAuth2 protocol, we have created a separate library [aerogear-ios-oauth2](https://github.com/aerogear/aerogear-ios-oauth2) that can be easily integrated, in order to provide  out-of-the-box support for communicated with OAuth2 protected endpoints. Please have a look at the "Http and OAuth2Module" section on our [documentation page](http://aerogear.org/docs/guides/aerogear-ios-2.X/Authorization/) for more information. 


Do you want to try it on your end? Follow next section steps.

> **NOTE:**  The library has been tested with Xcode 6.1.1

### Build, test and play with aerogear-ios-http

1. Clone this project

2. Get the dependencies

The project uses [aerogear-ios-httpstub](https://github.com/aerogear/aerogear-ios-httpstub) framework for stubbing its http network requests and utilizes [cocoapods](http://cocoapods.org) for handling it's dependencies. On the root directory of the project run:

```bash
bundle install
bundle exec pod install
```

3. open AeroGearHttp.xcworkspace

## Adding the library to your project 
To add the library in your project, you can either use [Cocoapods](http://cocoapods.org) or simply drag the library in your project. See the respective sections below for instructions

### Using [Cocoapods](http://cocoapods.org)
At this time, Cocoapods support for Swift frameworks is supported in a preview [branch](https://github.com/CocoaPods/CocoaPods/tree/swift) but tests shown that it's pretty stable to use. Simply [include a Gemfile](http://swiftwala.com/cocoapods-is-ready-for-swift/) in your project pointing to that branch and in your ```Podfile``` add:

```
pod 'AeroGearHttp'
```

and then:

```bash
bundle install
bundle exec pod install
```

to install your dependencies

### Drag the library in your project
Follow these steps to add the library in your Swift project.

1. [Clone this repository](#1-clone-this-repository)
2. [Add `AeroGearHttp.xcodeproj` to your application target](#2-add-aerogearhttp-xcodeproj-to-your-application-target)
3. Start writing your app!

#### 1. Clone this repository

```
git clone git@github.com:aerogear/aerogear-ios-http.git
```

#### 2. Add `AeroGearHttp.xcodeproj` to your application target

Right-click on the group containing your application target and select `Add Files To YourApp`
Next, select `AeroGearHttp.xcodeproj`, which you downloaded in step 1.


If you run into any problems, please [file an issue](http://issues.jboss.org/browse/AEROGEAR) and/or ask our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users). You can also join our [dev mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev).  

