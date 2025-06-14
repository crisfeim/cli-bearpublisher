// © 2025  Cristian Felipe Patiño Rojas. Created on 13/6/25.

import XCTest
import BearPublish

class BearSiteWriterTests: XCTestCase {
    
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    func test_execute_writesSiteToOutputURL() async throws {
        let index = Resource(filename: "index.html", contents: "index contents")
        let notes = [Resource(filename: "notes/somenote.html", contents: "some note contents")]
        let listsByCategory = [
            Resource(filename: "list/somecategorylist.html", contents: "some category list contents")
        ]
        let listsByTag = [
            Resource(filename: "tag/sometaglist.html", contents: "some tag list contents")
        ]
        
        let assets = [
            Resource(filename: "css/somecss.css", contents: "css content"),
            Resource(filename: "js/somejs.js", contents: "js content"),
        ]
        
        let site = BearRenderedSite(
            index: index,
            notes: notes,
            listsByCategory: listsByCategory,
            listsByTag: listsByTag,
            assets: assets
        )

        let filesFolder = testSpecificURL().appendingPathComponent("filesFolder")
        let imagesFolder = testSpecificURL().appendingPathComponent("imagesFolder")
        
        try FileManager.default.createDirectory(at: filesFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        
        
        let sut = BearSiteGenerator(
            site: site,
            outputURL: outputFolder(),
            filesFolderURL: filesFolder,
            imagesFolderURL: imagesFolder,
        )
        
        try await sut.execute()
      
        expectFileAtPathToExist("index.html")
        expectFileAtPathToExist("notes/somenote.html")
        expectFileAtPathToExist("list/somecategorylist.html")
        expectFileAtPathToExist("tag/sometaglist.html")
        expectFileAtPathToExist("css/somecss.css")
        expectFileAtPathToExist("js/somejs.js")
    }
}

// Custom expectations
private extension BearSiteWriterTests {
    func expectFileAtPathToExist(_ path: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssert(FileManager.default.fileExists(atPath: outputFolder().appendingPathComponent(path).path))
    }
}

// MARK: - Helpers
private extension BearSiteWriterTests {
    func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func testSpecificURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
    
    func outputFolder() -> URL {
        testSpecificURL().appendingPathComponent("output")
    }
}
