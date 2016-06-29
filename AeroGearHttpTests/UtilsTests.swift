//
//  UtilsTests.swift
//  AeroGearHttp
//
//  Created by Corinne Krych on 29/06/16.
//  Copyright © 2016 aerogear. All rights reserved.
//

import XCTest
import AeroGearHttp

class UtilsTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMergeDictionaryWithNBothNoNil () {
        let dict1 = ["dic1_key": "dict1_value"]
        let dict2 = ["dic2_key": "dict2_value"]
        var merged = merge(dict1, dict2)
        XCTAssertTrue(merged!["dic1_key"] == "dict1_value")
        XCTAssertTrue(merged!["dic2_key"] == "dict2_value")
    }
    
    func testMergeDictionaryWithNil () {
        let dict1 = ["dic1_key": "dict1_value"]
        let dict2:[String: String]? = nil
        var merged = merge(dict1, dict2)
        XCTAssertTrue(merged!["dic1_key"] == "dict1_value")
        let dict3:[String: String]? = nil
        let dict4:[String: String]? = ["dic4_key": "dict4_value"]
        var merged2 = merge(dict3, dict4)
        XCTAssertTrue(merged2!["dic4_key"] == "dict4_value")
    }
    
}
