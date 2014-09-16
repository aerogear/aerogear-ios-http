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

public class JsonRequestSerializer  : RequestSerializer {
    public var url: NSURL?
    public var headers: [String: String]?
    public var stringEncoding: NSNumber
    public var cachePolicy: NSURLRequestCachePolicy
    public var timeoutInterval: NSTimeInterval
    public var boundary = "BOUNDARY_STRING"
    
    public init(url: NSURL? = nil, headers: [String: String]? = nil) {
        self.url = url
        self.headers = headers
        self.stringEncoding = NSUTF8StringEncoding
        self.timeoutInterval = 60
        self.cachePolicy = .UseProtocolCachePolicy
    }
    
    public func request(url: NSURL, method: HttpMethod, parameters: [String: AnyObject]?, headers: [String: String]? = nil) -> NSURLRequest? {
        var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.toRaw()
        
        // apply headers to new request
        if(headers != nil) {
            for (key,val) in headers! {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }
        var queryString = ""
        if parameters != nil {
            queryString = self.stringFromParameters(parameters!)
        }

        if method == HttpMethod.GET || method == HttpMethod.HEAD || method == HttpMethod.DELETE {
            var paramSeparator = request.URL?.query != nil ? "&" : "?"
            var newUrl:String
            if (request.URL?.absoluteString != nil) {
                newUrl = "\(request.URL!.absoluteString!)\(paramSeparator)\(queryString)"
                request.URL = NSURL.URLWithString(newUrl)
            }
        } else {
            // POST, PUT
            var charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
            if request.valueForHTTPHeaderField("Content-Type") == nil {
                request.setValue("application/x-www-form-urlencoded; charset=\(charset)", forHTTPHeaderField:"Content-Type")
            }
            request.HTTPBody = queryString.dataUsingEncoding(NSUTF8StringEncoding)
        }
        return request
    }
    
    public func multiPartRequest(url:NSURL, method: HttpMethod, headers: [String: String]?) -> NSURLRequest? {
        assert(method == .POST || method == .PUT, "PUT or POST only")
        var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.toRaw()
        if(headers != nil) {
            for (key,val) in headers! {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }
        var contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField:"Content-Type")
        return request
    }
    
    func stringFromParameters(parameters: [String: AnyObject]) -> String {
        return join("&", map(serialize((nil, parameters)), {(tuple) in
            return self.stringValue(tuple)
            }))
    }
    
    func serialize(tuple: (String?, AnyObject)) -> [(String?, AnyObject)] {
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
    
    func stringValue(tuple: (String?, AnyObject)) -> String {
        func escapeString(raw: String) -> String {
            var nsString: NSString = raw
            var escapedString:NSString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, nsString, "[].",":/?&=;+!@#$()',*", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
            return escapedString as String
        }
        var val = ""
        if let str = tuple.1 as? String {
            val = str
        } else if tuple.1.description != nil {
            val = tuple.1.description
        }
  
        if tuple.0 == nil {
            return escapeString(val)
        }
        
        return "\(escapeString(tuple.0!))=\(escapeString(val))"
    }
    
}
