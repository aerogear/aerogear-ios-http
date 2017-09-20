# AeroGear iOS HTTP

![Maintenance](https://img.shields.io/maintenance/yes/2017.svg)
[![circle-ci](https://img.shields.io/circleci/project/github/aerogear/aerogear-ios-http/master.svg)](https://circleci.com/gh/aerogear/aerogear-ios-http)
[![License](https://img.shields.io/badge/-Apache%202.0-blue.svg)](https://opensource.org/s/Apache-2.0)
[![GitHub release](https://img.shields.io/github/release/aerogear/aerogear-ios-http.svg)](https://github.com/aerogear/aerogear-ios-http/releases)
[![CocoaPods](https://img.shields.io/cocoapods/v/AeroGearHttp.svg)](https://cocoapods.org/pods/AeroGearHttp)
[![Platform](https://img.shields.io/cocoapods/p/AeroGearHttp.svg)](https://cocoapods.org/pods/AeroGearHttp)

Thin layer to take care of your http requests working with NSURLSession.

|                 | Project Info                                 |
| --------------- | -------------------------------------------- |
| License:        | Apache License, Version 2.0                  |
| Build:          | CocoaPods                                    |
| Languague:      | Swift 4                                      |
| Documentation:  | http://aerogear.org/ios/                     |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS        |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))                            |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))                              |

- [Features](#features)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
- [Usage](#usage)
  - [Request](#request)
  - [Authentication](#authentication)
  - [OAuth2 Protocol Support](#oauth2-protocol-support)
- [Documentation](#documentation)
- [Demo apps](#demo-apps)
- [Development](#development)
- [Questions?](#questions)
- [Found a bug?](#found-a-bug)

## Features

* Json serializer
* Multipart upload
* HTTP Basic/Digest authentication support
* Pluggable object serialization
* background processing support

## Installation

### CocoaPods

In your `Podfile` add:

```bash
pod 'AeroGearHttp'
```

and then:

```bash
pod install
```

to install your dependencies

## Usage

### Request

To perform an HTTP request use the convenient methods found in the Http object. Here is an example usage:

```swift
let http = Http(baseURL: "http://server.com")

http.request(method: .get, path: "/get", completionHandler: {(response, error) in
     // handle response
})

http.request(method: .post, path: "/post",  parameters: ["key": "value"],
                    completionHandler: {(response, error) in
     // handle response
})
...
```

### Authentication

The library also leverages the build-in foundation support for http/digest authentication and exposes a convenient interface by allowing the credential object to be passed on the request. Here is an example:

> **NOTE:**  It is advised that HTTPS should be used when performing authentication of this type

```swift
let credential = URLCredential(user: "john",
                                 password: "pass",
                                 persistence: .none)

http.request(method: .get, path: "/protected/endpoint", credential: credential,
                                completionHandler: {(response, error) in
   // handle response
})
```

You can also set a credential per protection space, so it's automatically picked up once http challenge is requested by the server, thus omitting the need to pass the credential on each request. In this case, you must initialize the `Http` object with a custom session configuration object, that has its credentials storage initialized with your credentials:

```swift
// create a protection space
let protectionSpace = URLProtectionSpace(host: "httpbin.org",
                        port: 443,
                        protocol: NSURLProtectionSpaceHTTP,
                        realm: "me@kennethreitz.com",
                        authenticationMethod: NSURLAuthenticationMethodHTTPDigest)

// setup credential
// notice that we use '.ForSession' type otherwise credential storage will discard and
// won't save it when doing 'credentialStorage.setDefaultCredential' later on
let credential = URLCredential(user: "user",
                        password: "password",
                        persistence: .forSession)
// assign it to credential storage
let credentialStorage = URLCredentialStorage.shared
credentialStorage.setDefaultCredential(credential, for: protectionSpace);

// set up default configuration and assign credential storage
let configuration = URLSessionConfiguration.default
configuration.urlCredentialStorage = credentialStorage

// assign custom configuration to Http
let http = Http(baseURL: "http://httpbin.org", sessionConfig: configuration)
http.request(method: .get, path: "/protected/endpoint", completionHandler: {(response, error) in
    // handle response
})
```

### OAuth2 Protocol Support

To support the OAuth2 protocol, we have created a separate library [aerogear-ios-oauth2](https://github.com/aerogear/aerogear-ios-oauth2) that can be easily integrated, in order to provide  out-of-the-box support for communicating with OAuth2 protected endpoints. Please have a look at the "Http and OAuth2Module" section on our [documentation page](http://aerogear.org/docs/guides/aerogear-ios-2.X/Authorization/) for more information.

## Documentation

For more details about that please consult [our documentation](http://aerogear.org/ios/).

## Demo apps

Take a look in our demo apps:

* [ChuckNorrisJokes](https://github.com/aerogear/aerogear-ios-cookbook/tree/master/ChuckNorrisJokes)
* [Weather](https://github.com/aerogear/aerogear-ios-cookbook/tree/master/Weather)
* [Shoot and Share](https://github.com/aerogear/aerogear-ios-cookbook/tree/master/Shoot)

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.
