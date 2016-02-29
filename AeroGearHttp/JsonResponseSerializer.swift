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
A response deserializer to JSON objects.
*/
public class JsonResponseSerializer : ResponseSerializer {
    
    /**
     Validate the response received. throw an error is the response is not va;id.
     
     :returns:  either true or false if the response is valid for this particular serializer.
     */
    public var validateResponse: (NSURLResponse!, NSData) throws -> Void = { (response: NSURLResponse!, data: NSData) -> Void in
        var error: NSError! = NSError(domain: "AeroGearHttp", code: 0, userInfo: nil)
        let httpResponse = response as! NSHTTPURLResponse
        let dataAsJson: [String: AnyObject]?
        
        // validate JSON
        do {
            dataAsJson = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
        } catch  _  {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid response received, can't parse JSON" as NSString,
                NetworkingOperationFailingURLResponseErrorKey: response]
            let customError = NSError(domain: HttpResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
            throw customError;
        }
        
        if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            var userInfo = [NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode),
                NetworkingOperationFailingURLResponseErrorKey: response]
            if let dataAsJson = dataAsJson {
                userInfo["CustomData"] = dataAsJson
            }
            error = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
            throw error
        }
    }
    
    /**
    Deserialize the response received.
    
    :returns: the serialized response
    */
    public var response: (NSData, Int) -> AnyObject? = { (data: NSData, Int) -> AnyObject? in
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        } catch _ {
            return nil
        }
    }
    
    public init() {
    }
    
    public init(validateResponse: (NSURLResponse!, NSData) throws -> Void, response: (NSData, Int) -> AnyObject?) {
        self.validateResponse = validateResponse
        self.response = response
    }
    
    public init(validateResponse: (NSURLResponse!, NSData) throws -> Void) {
        self.validateResponse = validateResponse
    }
    
    public init(response: (NSData, Int) -> AnyObject?) {
        self.response = response
    }
}