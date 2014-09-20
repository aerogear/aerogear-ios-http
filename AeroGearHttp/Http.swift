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

    var baseURL: NSURL
    var session: NSURLSession
    var requestSerializer: RequestSerializer
    var responseSerializer: ResponseSerializer
    var authzModule: AuthzModule?
    
    public convenience init(url: String) {
        self.init(url: url, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    public convenience init(url: String, sessionConfig: NSURLSessionConfiguration) {
        self.init(url: url,
            sessionConfig: sessionConfig,
            requestSerializer: JsonRequestSerializer(url: url),
            responseSerializer: JsonResponseSerializer())
    }
    
    public init(url: String, sessionConfig: NSURLSessionConfiguration, requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer) {
        self.baseURL = NSURL.URLWithString(url)
        self.session = NSURLSession(configuration: sessionConfig)
        self.requestSerializer = requestSerializer
        self.responseSerializer = responseSerializer
    }
    
    func call(url: NSURL, method: HttpMethod, parameters: Dictionary<String, AnyObject>?, completionHandler: (AnyObject?, NSError?) -> Void) {
        
        let serializedRequest = requestSerializer.request(url, method: method, parameters: parameters, headers: self.authzModule?.authorizationFields())
        
        if (serializedRequest != nil) {
            let task = session.dataTaskWithRequest(serializedRequest!,
                completionHandler: {(data, response, error) in
                    if error != nil {
                        completionHandler(nil, error)
                        return
                    }
                    var httpResponse = response as NSHTTPURLResponse
                    if httpResponse.statusCode == 401 && self.authzModule != nil {
                        
                            self.authzModule!.requestAccess({ (response, error) in
                                // replay request
                                self.call(self.baseURL, method: method, parameters: parameters, completionHandler: completionHandler)

                            })

                    } else {
                        
                        var error: NSError?
                        var isValid = self.responseSerializer.validateResponse(response, data: data, error: &error)
                        
                        if (isValid == false) {
                            completionHandler(nil, error)
                            return
                        }
                    
                        if data != nil {
                            var responseObject: AnyObject? = self.responseSerializer.response(data)
                            completionHandler(responseObject, nil)
                        }
                    }
            })
            
            // schedule task
            task.resume()
        }
    }
    
    public func GET(parameters: [String: AnyObject]? = nil, completionHandler: (AnyObject?, NSError?) -> Void) {
        self.call(baseURL, method: .GET, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func POST(parameters: [String: AnyObject]? = nil, completionHandler: (AnyObject?, NSError?) -> Void) {
        self.call(baseURL, method: .POST, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func PUT(parameters: [String: AnyObject]? = nil, completionHandler: (AnyObject?, NSError?) -> Void) {
        self.call(baseURL, method: .PUT, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func DELETE(parameters: [String: AnyObject]? = nil, completionHandler: (AnyObject?, NSError?) -> Void) {
        self.call(baseURL, method: .DELETE, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func HEAD(parameters: [String: AnyObject]? = nil, completionHandler: (AnyObject?, NSError?) -> Void) {
        self.call(baseURL, method: .HEAD, parameters: parameters, completionHandler: completionHandler)
    }
    
    // TODO add retry for sealless integration http-authz
    public func multiPartUpload(url: NSURL, parameters: [String: AnyObject], completionHandler: (AnyObject?, NSError?) -> Void) {
        
        let serializedRequest = requestSerializer.multiPartRequest(url, method: .POST, headers: self.authzModule?.authorizationFields())
        
        var body = buildBody(parameters)
        if (serializedRequest != nil) {
            let task = session.uploadTaskWithRequest(serializedRequest!,
                fromData: body,
                completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                    if error != nil {
                        completionHandler(nil, error)
                        return
                    }
                    var error: NSError?
                    var isValid = self.responseSerializer.validateResponse(response, data: data, error: &error)
                    if (isValid == false) {
                        completionHandler(nil, error)
                        return
                    }
                    if data != nil {
                        var responseObject: AnyObject? = self.responseSerializer.response(data)
                        completionHandler(responseObject, nil)
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