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
    
    public func response(data: NSData) -> (AnyObject?) {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
    }

    public func validateResponse(response: NSURLResponse!, data: NSData, error: NSErrorPointer) -> Bool {
        let httpResponse = response as NSHTTPURLResponse
        
        if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            var userInfo = [
                NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode),
                NetworkingOperationFailingURLResponseErrorKey: response]

            if (error != nil) {
                error.memory = NSError(domain: HttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
            }
            
            return false
        }
        
        // validate JSON
        if (nil == NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)) {
            let userInfo = [
                NSLocalizedDescriptionKey: "Invalid response received, can't parse JSON" as NSString,
                NetworkingOperationFailingURLResponseErrorKey: response]
            
            if (error != nil) {
                error.memory = NSError(domain: HttpResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
            }
            
            return false;
        }
        
        return true
    }
    
    public init() {
    }
}