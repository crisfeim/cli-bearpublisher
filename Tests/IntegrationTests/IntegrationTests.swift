// © 2025  Cristian Felipe Patiño Rojas. Created on 9/6/25.

import XCTest
import BearPublish
@testable import BearPublishCLI

class IntegrationTests: XCTestCase {
    
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    private var filesFolder: URL {
        testSpecificURL().appendingPathComponent("files")
    }
    
    private var imagesFolder: URL {
        testSpecificURL().appendingPathComponent("images")
    }
    
    
    private var dbPath: String {
        Bundle.module.url(forResource: "database", withExtension: "sqlite")!.path
    }
    
    func test_cli_buildsExpectedFilesAtOutputURL() async throws {
        try FileManager.default.createDirectory(at: filesFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        let cli = try BearPublisherCLI.parse([
            "--db-path", dbPath,
            "--output", outputFolder().path,
            "--images-folder-path", imagesFolder.path,
            "--files-folder-path", filesFolder.path,
            "--title", "Test Site"
        ])
        
        try await cli.run()
        expectSiteToExist()
    }
    
    func test_bearPublisherComposerExecute_buildsExpectedFilesAtOutputURL() async throws {
        try FileManager.default.createDirectory(at: filesFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        let sut = try BearPublisherComposer.make(
            dbPath: dbPath,
            outputURL: outputFolder(),
            filesFolderURL: filesFolder,
            imagesFolderURL: imagesFolder,
            siteTitle: "any title"
        )
        
        try await sut.execute()
        expectSiteToExist()
    }
}

// MARK: - Custom asserts
private extension IntegrationTests {
    
    func expectSiteToExist(file: StaticString = #filePath, line: UInt = #line){
        expectFileAtPathToExist("index.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/archived-note.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/encrypted-note.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/note-with-done-tasks.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/note-with-file.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/note-with-source-code.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/note-with-tag.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/note-with-undone-tasks.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/pinned-note.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/regular-note.html", file: file, line: line)
        expectFileAtPathToExist("standalone/note/trashed-note.html", file: file, line: line)
        expectFileAtPathToExist("standalone/list/all.html", file: file, line: line)
        expectFileAtPathToExist("standalone/list/archived.html", file: file, line: line)
        expectFileAtPathToExist("standalone/list/tasks.html", file: file, line: line)
        expectFileAtPathToExist("standalone/list/trashed.html", file: file, line: line)
        expectFileAtPathToExist("standalone/tag/code.html", file: file, line: line)
        expectFileAtPathToExist("standalone/tag/dev.html", file: file, line: line)
        expectFileAtPathToExist("standalone/tag/sometag.html", file: file, line: line)
        expectFileAtPathToExist("standalone/tag/sometag&nested.html", file: file, line: line)
        expectFileAtPathToExist("standalone/tag/sometag&nested&nested.html", file: file, line: line)
        expectFileAtPathToExist("assets/css", file: file, line: line)
        expectFileAtPathToExist("assets/js", file: file, line: line)

        expectFileWithHashToExist(parentFolder: "assets/css", fileNamePrefix: "theme-variables", file: file, line: line)
        expectFileWithHashToExist(parentFolder: "assets/css", fileNamePrefix: "styles", file: file, line: line)
        expectFileWithHashToExist(parentFolder: "assets/js", fileNamePrefix: "htmx", file: file, line: line)
        expectFileWithHashToExist(parentFolder: "assets/js", fileNamePrefix: "hyperscript", file: file, line: line)
        expectFileWithHashToExist(parentFolder: "assets/js", fileNamePrefix: "main", file: file, line: line)
    }
    
    func expectFileWithHashToExist(parentFolder: String, fileNamePrefix: String, file: StaticString = #filePath, line: UInt = #line) {
        
        do {
            let directoryURL = outputFolder().appendingPathComponent(parentFolder)
            
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil
            )
            
            let cssFile = contents.first {
                $0.lastPathComponent.hasPrefix(fileNamePrefix)
            }
            
            XCTAssertNotNil(cssFile, "Expected to find a '\(fileNamePrefix)-<hash>' file in \(directoryURL.path)", file: file, line: line)
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }
    
    func expectFileAtPathToExist(_ path: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssert(FileManager.default.fileExists(atPath: outputFolder().appendingPathComponent(path).path))
    }
}


// MARK: - Helpers
private extension IntegrationTests {
    
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


// MARK: - My beloved asterisk
infix operator .*: AdditionPrecedence

@discardableResult
func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}
