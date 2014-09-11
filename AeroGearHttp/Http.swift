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

public class Http {
    public var baseURL: NSURL?
    var session: NSURLSession
    public var requestSerializer: RequestSerializer
    public var responseSerializer: ResponseSerializer
    
    public convenience init() {
        self.init(url: nil)
    }
    
    public convenience init(url: String?) {
        self.init(url: url, sessionConfig: nil)
    }
    
    public convenience init(url: String?, sessionConfig: NSURLSessionConfiguration?, headers: [String: String] = [String: String]()) {
        let baseURL = url == nil ? nil : NSURL.URLWithString(url!)
        self.init(url: url, sessionConfig: sessionConfig, requestSerializer: JsonRequestSerializer(url: baseURL, headers: headers), responseSerializer: JsonResponseSerializer())
    }
    
    public init(url: String?, sessionConfig: NSURLSessionConfiguration?, requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer) {
        self.baseURL = url == nil ? nil : NSURL.URLWithString(url!)
        self.session = (sessionConfig == nil) ? NSURLSession.sharedSession() : NSURLSession(configuration: sessionConfig!)
        self.requestSerializer = requestSerializer
        self.responseSerializer = responseSerializer
    }
    
    func call(url: NSURL, method: HttpMethod, parameters: Dictionary<String, AnyObject>?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> Void {
        
        let serializedRequest = requestSerializer.request(url, method: method, parameters: parameters)
        
        if (serializedRequest != nil) {
            let task = session.dataTaskWithRequest(serializedRequest!,
                completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                    if error != nil {
                        failure(error)
                        return
                    }
                    var myError = NSError()
                    var isValid = self.responseSerializer.validateResponse(response, data: data, error: &myError)
                    if (isValid == false) {
                        failure(myError)
                        return
                    }
                    if data != nil {
                        var responseObject: AnyObject? = self.responseSerializer.response(data)
                        success(responseObject)
                    }
            })
            task.resume()
        }
    }
    
    public func GET(parameters: [String: AnyObject]? = nil, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        if let unwrappedURL = baseURL {
            self.call(unwrappedURL, method: .GET, parameters: parameters, success, failure)
        }
    }
    
    public func POST(parameters: [String: AnyObject]? = nil, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        if let unwrappedURL = baseURL {
            self.call(unwrappedURL, method: .POST, parameters: parameters, success, failure)
        }
    }
    
    public func PUT(parameters: [String: AnyObject]? = nil, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        if let unwrappedURL = baseURL {
            self.call(unwrappedURL, method: .PUT, parameters: parameters, success, failure)
        }
    }
    
    public func DELETE(parameters: [String: AnyObject]? = nil, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        if let unwrappedURL = baseURL {
            self.call(unwrappedURL, method: .DELETE, parameters: parameters, success, failure)
        }
    }
    
    public func HEAD(parameters: [String: AnyObject]? = nil, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        if let unwrappedURL = baseURL {
            self.call(unwrappedURL, method: .HEAD, parameters: parameters, success, failure)
        }
    }
    
    public func multiPartUpload(url: NSURL, parameters: [String: AnyObject], success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        
        let serializedRequest = requestSerializer.multiPartRequest(url, method: .POST)
        
        var body = buildBody(parameters)
        if (serializedRequest != nil) {
            let task = session.uploadTaskWithRequest(serializedRequest!,
                fromData: body,
                completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                    if error != nil {
                        failure(error)
                        return
                    }
                    var myError = NSError()
                    var isValid = self.responseSerializer.validateResponse(response, data: data, error: &myError)
                    if (isValid == false) {
                        failure(myError)
                        return
                    }
                    if data != nil {
                        var responseObject: AnyObject? = self.responseSerializer.response(data)
                        success(responseObject)
                    }
            })
            task.resume()
        }
    }
    
    func buildBody(parameters: [String: AnyObject]) -> NSData {
        var body: NSMutableData = NSMutableData()
        
        for (key, value) in parameters {
            if (value is NSData) {
                body.appendData("\r\n--\(requestSerializer.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                // TODO AGIOS-229 fileName associated with image similar to FilePart
                body.appendData("Content-Disposition: form-data; name=\"photo\"; filename=\"filename.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                //body
            } else {
                body.appendData("\r\n--\(requestSerializer.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
                
            }
        }
        body.appendData("\r\n--\(requestSerializer.boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("".dataUsingEncoding(NSUTF8StringEncoding)!)
        return body
    }
    
}