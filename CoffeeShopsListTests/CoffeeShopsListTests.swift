//
//  CoffeeShopsListTests.swift
//  CoffeeShopsListTests
//
//  Created by Venkat Madira on 25/01/2021.
//

import XCTest
@testable import CoffeeShopsList

class CoffeeShopsListTests: XCTestCase {
    var coffeeTableVC = ListVC()
    
    
    func testInitializing(){
        XCTAssertNotNil(coffeeTableVC, "Coffee List Table View Controller did not load")
       
    }
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
   
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testHasATableView() {
        XCTAssertNotNil(self.coffeeTableVC.tableView)
        }
        
        func testTableViewHasDelegate() {
            XCTAssertNotNil(self.coffeeTableVC.tableView.delegate)
        }
        
        func testTableViewConfirmsToTableViewDelegateProtocol() {
            XCTAssertTrue(self.coffeeTableVC.conforms(to: UITableViewDelegate.self))
            XCTAssertTrue(self.coffeeTableVC.responds(to: #selector(self.coffeeTableVC.tableView(_:didSelectRowAt:))))
        }
        
        func testTableViewHasDataSource() {
            XCTAssertNotNil(self.coffeeTableVC.tableView.dataSource)
        }
    func testTableViewConformsToTableViewDataSourceProtocol() {
            XCTAssertTrue(self.coffeeTableVC.conforms(to: UITableViewDataSource.self))
            XCTAssertTrue(self.coffeeTableVC.responds(to: #selector(self.coffeeTableVC.numberOfSections(in:))))
            XCTAssertTrue(self.coffeeTableVC.responds(to: #selector(self.coffeeTableVC.tableView(_:numberOfRowsInSection:))))
            XCTAssertTrue(self.coffeeTableVC.responds(to: #selector(self.coffeeTableVC.tableView(_:cellForRowAt:))))
        }

    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
