/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

class AGSessionImpl : AGSession {
    var baseURL: NSURL
    var session: NSURLSession
    var requestSerializer: AGRequestSerializer!
    var responseSerializer: AGResponseSerializer!
    
    init(url: String) {
        // TODO check valid url
        assert(url != nil, "baseURL is required")
        self.baseURL = NSURL.URLWithString(url)
        session = NSURLSession.sharedSession()
        requestSerializer = AGRequestSerializerImpl(url: self.baseURL, headers: [String: String]())
        responseSerializer = AGResponseSerializerImpl()
    }
    
//    init(url: String, sessionConfig: NSURLSessionConfiguration) {
//        assert(url != nil, "baseURL is required")
//        self.baseURL = NSURL.URLWithString(url)
//        session = NSURLSession(configuration: sessionConfig)
//        requestSerializer = AGRequestSerializerImpl(url: baseURL, headers: [String: String]())
//        responseSerializer = AGResponseSerializerImpl()
//    }

    func call(url: NSURL, method: AGHttpMethod, parameters: Dictionary<String, AnyObject>?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> () {
        
        let serializedRequest = requestSerializer.request(method, parameters: parameters)
        
        let task = session.dataTaskWithRequest(serializedRequest,
            completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                println("response\(response)")
                if error {
                    failure(error)
                    return
                }
                var myError = NSError()
                var isValid = self.responseSerializer?.validateResponse(response, data: data, error: &myError)
                if (isValid == false) {
                    failure(myError)
                    return
                }
                if data {
                    var responseObject: AnyObject? = self.responseSerializer?.response(data)
                    success(responseObject)
                }
            })
        task.resume()
    }
    
    func GET(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {
        self.call(self.baseURL, method: .GET, parameters: parameters, success, failure)
    }
    
    func POST(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {
        self.call(self.baseURL, method: .POST, parameters: parameters, success, failure)
    }
    
    func PUT(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {
        self.call(self.baseURL, method: .PUT, parameters: parameters, success, failure)
    }
    
    func DELETE(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {
        self.call(self.baseURL, method: .DELETE, parameters: parameters, success, failure)
    }
    
    func HEAD(parameters: [String: AnyObject]?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {
        self.call(self.baseURL, method: .HEAD, parameters: parameters, success, failure)
    }
    
    func multiPartUpload(parameters: [String: AnyObject], success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {

        let serializedRequest = requestSerializer.multiPartRequest(.POST)
        
        var body = buildBody(parameters)

        let task = session.uploadTaskWithRequest(serializedRequest,
            fromData: body,
            completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                println("response\(response)")
                if error {
                    failure(error)
                    return
                }
                var myError = NSError()
                var isValid = self.responseSerializer?.validateResponse(response, data: data, error: &myError)
                if (isValid == false) {
                    failure(myError)
                    return
                }
                if data {
                    var responseObject: AnyObject? = self.responseSerializer?.response(data)
                    success(responseObject)
                }
            })
        task.resume()
    }
    
    func buildBody(parameters: [String: AnyObject]) -> NSData {
        var body: NSMutableData = NSMutableData()
        
        for (key, value) in parameters {
            if (value is NSData) {
                body.appendData("\r\n--\(requestSerializer.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding))
                // TODO fileName associated with image similar to AGFilePart
                body.appendData("Content-Disposition: form-data; name=\"photo\"; filename=\"filename.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding))
                //body
            } else {
                body.appendData("\r\n--\(requestSerializer.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding))
                body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding))
                
            }
        }
        body.appendData("\r\n--\(requestSerializer.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding))
        body.appendData("".dataUsingEncoding(NSUTF8StringEncoding))
        return body
    }
    
}