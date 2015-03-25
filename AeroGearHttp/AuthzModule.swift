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
The protocol that authorization modules must adhere to.
*/
public protocol AuthzModule {

    /**
    Gateway to request authorization access.
    
    :param: completionHandler A block object to be executed when the request operation finishes.
    */
    func requestAccess(completionHandler: (AnyObject?, NSError?) -> Void)
    
    /**
    Return any authorization fields.
    
    :param: url used for oauth1 which required signature of the method
    :param: parameters used for oauth1 which required signature of the method. it should be all parameters (oauth1 plus additional one)
    
    :returns:  a dictionary filled with the authorization fields.
    */
    func authorizationFields(url: String?, parameters: [String: AnyObject]?) -> [String: String]?
    
}