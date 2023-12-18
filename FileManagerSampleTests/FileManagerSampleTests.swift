//
//  FileManagerSampleTests.swift
//  FileManagerSampleTests
//
//  Created by Htain Lin Shwe on 18/12/2023.
//

import XCTest
@testable import FileManagerSample

final class FileManagerSampleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveFile() throws {
        
        let model = HomeViewModel()
        if let image = UIImage(named: "image1") {
            
            let exception = expectation(description: "Save the Image")
            
            model.saveTheImage(name: "hello.png", type: "png", image: image) { success in
                if success == false {
                    XCTFail("Saving Image Fail")
                    exception.fulfill()
                }
                else {
                    model.loadTheImage(name: "hello.png") { image in
                        XCTAssertNotNil(image)
                        exception.fulfill()
                    }
                }
            }
            
            waitForExpectations(timeout: 5)
            
        }
        else {
            XCTFail("Image Cannot Load")
        }
    }



}
