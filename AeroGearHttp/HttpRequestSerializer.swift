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

/**
An HttpRequest serializer that handles form-encoded URL requess including multipart support.
*/
public class HttpRequestSerializer:  RequestSerializer {
    
    public var url: NSURL?
    public var headers: [String: String]?
    public var stringEncoding: NSNumber
    public var cachePolicy: NSURLRequestCachePolicy
    public var timeoutInterval: NSTimeInterval
    
    public init() {
        self.stringEncoding = NSUTF8StringEncoding
        self.timeoutInterval = 60
        self.cachePolicy = .UseProtocolCachePolicy
    }
    
    public func request(url: NSURL, method: HttpMethod, parameters: [String: AnyObject]?, headers: [String: String]? = nil) -> NSURLRequest {
        var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.rawValue
        
        // apply headers to new request
        if(headers != nil) {
            for (key,val) in headers! {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }
        
        if method == HttpMethod.GET || method == HttpMethod.HEAD || method == HttpMethod.DELETE {
            var paramSeparator = request.URL?.query != nil ? "&" : "?"
            var newUrl:String
            if (request.URL?.absoluteString != nil && parameters != nil) {
                let queryString = self.stringFromParameters(parameters!)
                newUrl = "\(request.URL!.absoluteString!)\(paramSeparator)\(queryString)"
                request.URL = NSURL(string: newUrl)!
            }
            
        } else {
            // set type
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // set body
            if (parameters != nil) {
                var body = self.stringFromParameters(parameters!).dataUsingEncoding(NSUTF8StringEncoding)
                request.setValue("\(body?.length)", forHTTPHeaderField: "Content-Length")
                request.HTTPBody = body
            }
        }
        
        return request
    }
    
    public func multipartRequest(url: NSURL, method: HttpMethod, parameters: [String: AnyObject]?, headers: [String: String]? = nil) -> NSURLRequest {
        var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.rawValue
        
        // apply headers to new request
        if(headers != nil) {
            for (key,val) in headers! {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }
        
        let boundary = "AG-boundary-\(arc4random())-\(arc4random())"
        var type = "multipart/form-data; boundary=\(boundary)"
        var body = self.multiPartBodyFromParams(parameters!, boundary: boundary)

        request.setValue(type, forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        request.HTTPBody = body
        
        return request
    }
    
    public func stringFromParameters(parameters: [String: AnyObject]) -> String {
        return join("&", map(serialize((nil, parameters)), {(tuple) in
            return self.stringValue(tuple)
        }))
    }
    
    public func serialize(tuple: (String?, AnyObject)) -> [(String?, AnyObject)] {
        var collect:[(String?, AnyObject)] = []
        if let array = tuple.1 as? [AnyObject] {
            for nestedValue : AnyObject in array {
                let label: String = tuple.0!
                var myTuple:(String?, AnyObject) = (label + "[]", nestedValue)
                collect.extend(self.serialize(myTuple))
            }
        } else if let dict = tuple.1 as? [String: AnyObject] {
            for (nestedKey, nestedObject: AnyObject) in dict {
                var newKey = tuple.0 != nil ? "\(tuple.0)[\(nestedKey)]" : nestedKey
                var myTuple:(String?, AnyObject) = (newKey, nestedObject)
                collect.extend(self.serialize(myTuple))
            }
        } else {
            collect.append((tuple.0, tuple.1))
        }
        return collect
    }
    
    public func stringValue(tuple: (String?, AnyObject)) -> String {
        var val = ""
        if let str = tuple.1 as? String {
            val = str
        } else if tuple.1.description != nil {
            val = tuple.1.description
        }
        
        if tuple.0 == nil {
            return val.urlEncode()
        }
        
        return "\(tuple.0!.urlEncode())=\(val.urlEncode())"
    }
    
    public func multiPartBodyFromParams(parameters: [String: AnyObject], boundary: String) -> NSData {
        var data = NSMutableData()
        
        let prefixData = "--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        let seperData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        for (key, value) in parameters {
            var sectionData: NSData?
            var sectionType: String?
            var sectionFilename = ""
            
            if value is MultiPartData {
                let multiData = value as MultiPartData
                sectionData = multiData.data
                sectionType = multiData.mimeType
                sectionFilename = " filename=\"\(multiData.filename)\""
            } else {
                sectionData = "\(value)".dataUsingEncoding(NSUTF8StringEncoding)
            }
            
            data.appendData(prefixData!)
            
            let sectionDisposition = "Content-Disposition: form-data; name=\"\(key)\";\(sectionFilename)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
            data.appendData(sectionDisposition!)
            
            if let type = sectionType {
                let contentType = "Content-Type: \(type)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
                data.appendData(contentType!)
            }
            
            // append data
            data.appendData(seperData!)
            data.appendData(sectionData!)
            data.appendData(seperData!)
        }
        
        data.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return data
    }
    
    public func hasMultiPartData(parameters: [String: AnyObject]?) -> Bool {
        if (parameters == nil) {
            return false
        }
        
        var isMultiPart = false
        for (_, value) in parameters! {
            if value is MultiPartData {
                isMultiPart = true
                break
            }
        }
        
        return isMultiPart
    }
}
