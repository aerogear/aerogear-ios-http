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

let HtttpResponseSerializationErrorDomain = "org.aerogear.http.response";


class JsonResponseSerializer : ResponseSerializer {
    
    func response(data: NSData) -> (AnyObject?) {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)
    }

    func validateResponse(response: NSURLResponse!, data: NSData!, inout error: NSError) -> Bool {
        let httpResponse = response as NSHTTPURLResponse
        var isValid = true

        if !(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            isValid = false
            var userInfo = [
                NSLocalizedDescriptionKey: "Request failed: \(httpResponse.statusCode)",
                NSURLErrorFailingURLErrorKey: httpResponse.URL
            ]
            
            error = NSError(domain: HtttpResponseSerializationErrorDomain, code: httpResponse.statusCode, userInfo: userInfo)
        }
        
        return isValid
    }
}