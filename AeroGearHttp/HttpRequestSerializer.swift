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
    /// The url that this request serializer is bound to.
    public var url: NSURL?
    /// Any headers that will be appended on the request.
    public var headers: [String: String]?
    /// The String encoding to be used.
    public var stringEncoding: NSNumber
    ///  The cache policy.
    public var cachePolicy: NSURLRequestCachePolicy
    /// The timeout interval.
    public var timeoutInterval: NSTimeInterval
    
    /// Defualt initializer.
    public init() {
        self.stringEncoding = NSUTF8StringEncoding
        self.timeoutInterval = 60
        self.cachePolicy = .UseProtocolCachePolicy
    }
    
    /**
    Build an request using the specified params passed in.
    
    :param: url the url of the resource.
    :param: method the method to be used.
    :param: parameters the request parameters.
    :param: headers any headers to be used on this request.
    
    :returns: the URLRequest object.
    */
    public func request(url: NSURL, method: HttpMethod, parameters: [String: AnyObject]?, headers: [String: String]? = nil) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.rawValue
        
        // apply headers to new request
        if(headers != nil) {
            for (key,val) in headers! {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }
        
        if method == HttpMethod.GET || method == HttpMethod.HEAD || method == HttpMethod.DELETE {
            let paramSeparator = request.URL?.query != nil ? "&" : "?"
            var newUrl:String
            if (request.URL?.absoluteString != nil && parameters != nil) {
                let queryString = self.stringFromParameters(parameters!)
                newUrl = "\(request.URL!.absoluteString)\(paramSeparator)\(queryString)"
                request.URL = NSURL(string: newUrl)!
            }
            
        } else {
            // set type
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // set body
            if (parameters != nil) {
                let body = self.stringFromParameters(parameters!).dataUsingEncoding(NSUTF8StringEncoding)
                request.setValue("\(body?.length)", forHTTPHeaderField: "Content-Length")
                request.HTTPBody = body
            }
        }
        
        return request
    }
    
    /**
    Build an multipart request using the specified params passed in.
    
    :param: url the url of the resource.
    :param: method the method to be used.
    :param: parameters the request parameters.
    :param: headers  any headers to be used on this request.
    
    :returns: the URLRequest object
    */
    public func multipartRequest(url: NSURL, method: HttpMethod, parameters: [String: AnyObject]?, headers: [String: String]? = nil) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.rawValue
        
        // apply headers to new request
        if(headers != nil) {
            for (key,val) in headers! {
                request.addValue(val, forHTTPHeaderField: key)
            }
        }
        
        let boundary = "AG-boundary-\(arc4random())-\(arc4random())"
        let type = "multipart/form-data; boundary=\(boundary)"
        let body = self.multiPartBodyFromParams(parameters!, boundary: boundary)

        request.setValue(type, forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        request.HTTPBody = body
        
        return request
    }
    
    public func stringFromParameters(parameters: [String: AnyObject]) -> String {
        let parametersArray = serialize((nil, parameters)).map({(tuple) in
            return self.stringValue(tuple)
        })
        return parametersArray.joinWithSeparator("&")
//        return "&".join(serialize((nil, parameters)).map({(tuple) in
//            return self.stringValue(tuple)
//        }))
    }
    
    public func serialize(tuple: (String?, AnyObject)) -> [(String?, AnyObject)] {
        var collect:[(String?, AnyObject)] = []
        if let array = tuple.1 as? [AnyObject] {
            for nestedValue : AnyObject in array {
                let label: String = tuple.0!
                let myTuple:(String?, AnyObject) = (label + "[]", nestedValue)
                collect.appendContentsOf(self.serialize(myTuple))
            }
        } else if let dict = tuple.1 as? [String: AnyObject] {
            for (nestedKey, nestedObject) in dict {
                let newKey = tuple.0 != nil ? "\(tuple.0!)[\(nestedKey)]" : nestedKey
                let myTuple:(String?, AnyObject) = (newKey, nestedObject)
                collect.appendContentsOf(self.serialize(myTuple))
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
        let data = NSMutableData()
        
        let prefixData = "--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        let seperData = "\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        for (key, value) in parameters {
            var sectionData: NSData?
            var sectionType: String?
            var sectionFilename = ""
            
            if value is MultiPartData {
                let multiData = value as! MultiPartData
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
