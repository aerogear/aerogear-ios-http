// To run this playground, follow the instruction in README.md

import XCPlayground
import AeroGearHttp

// Simple GET
var url = "http://api.icndb.com/jokes/1"
var http = Session(url: url, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
http.GET(success: {(response: AnyObject?) in
    if let unwrappedResponse = response as? Dictionary<String, AnyObject> {
        println("Success: \(unwrappedResponse)")
    }
    }, failure: {(error: NSError) in
        println("Error")
})

// Simple POST
var urlPost = "http://httpbin.org/post"
var httpPost = Session(url: urlPost, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
httpPost.POST(success: {(response: AnyObject?) in
    if let unwrappedResponse = response as? Dictionary<String, AnyObject> {
        println("Success: \(unwrappedResponse)")
    }
    }, failure: {(error: NSError) in
        println("Error")
})


XCPSetExecutionShouldContinueIndefinitely()
