// © 2025  Cristian Felipe Patiño Rojas. Created on 13/6/25.

import XCTest
import BearDomain
import BearPublish

class BearPublisherTests: XCTestCase {
    
    override func setUp() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: testSpecificURL())
    }

    func test_execute_buildsTheExpectedSiteAtOutputURL() async throws {
        struct IndexRenderer: BearSiteRenderer.IndexRenderer {
            func render(title: String, lists: [NoteList], notes: [Note], tags: [Tag]) -> Resource {
                Resource(filename: "index.html", contents: "index rendered contents")
            }
        }
        
        struct NoteRenderer: BearSiteRenderer.NoteRenderer {
            func render(title: String, slug: String, content: String) -> Resource {
                Resource(filename: "note/\(slug).html", contents: "note rendered content")
            }
        }
        
        struct ListByCategoryRenderer: BearSiteRenderer.ListRenderer {
            func render(title: String, slug: String, notes: [Note]) -> Resource {
                Resource(filename: "list/\(slug).html", contents: "list rendered content")
            }
        }
        
        struct ListByTagRenderer: BearSiteRenderer.ListRenderer {
            func render(title: String, slug: String, notes: [Note]) -> Resource {
                Resource(filename: "tag/\(slug).html", contents: "list rendered content")
            }
        }
        
        let filesFolder = testSpecificURL().appendingPathComponent("filesFolder")
        let imagesFolder = testSpecificURL().appendingPathComponent("imagesFolder")
        
        try FileManager.default.createDirectory(at: filesFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        
        let sut = try BearPublisher(
            outputURL: outputFolder(),
            siteTitle: "Home",
            indexNotesProvider: { [Self.anyNote()] },
            notesProvider: { [Self.anyNote()] },
            tagProvider: { [Self.anyTag()] },
            categoryListProvider: { [Self.anyNoteList()] },
            tagListProvider: { [Self.anyNoteList()] },
            indexRenderer: IndexRenderer(),
            noteRenderer: NoteRenderer(),
            listByCategoryRenderer: ListByCategoryRenderer(),
            listByTagRenderer: ListByTagRenderer(),
            filesFolderURL: filesFolder,
            imagesFolderURL: imagesFolder,
            assetsProvider: {
                [Resource(filename: "css/some.css", contents: "Some css")]
            })
        
        try await sut.execute()
        
        expectFileAtPathToExist("index.html")
        expectFileAtPathToExist("note/\(Self.anyNote().slug).html")
        expectFileAtPathToExist("list/\(Self.anyNoteList().slug).html")
        expectFileAtPathToExist("tag/\(Self.anyNoteList().slug).html")
        expectFileAtPathToExist("css/some.css")
        expectFileAtPathToExist("images")
        expectFileAtPathToExist("files")
    }
}


private extension BearPublisherTests {
    #warning("@todo: Assert file contets")
    func expectFileAtPathToExist(_ path: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssert(FileManager.default.fileExists(atPath: outputFolder().appendingPathComponent(path).path))
    }
}

// MARK: - Helpers
#warning("@todo: Extract helpers into common scope")
private extension BearPublisherTests {
    
     static func anyNote() -> Note {
        Note(
            id: 0,
            title: "any note",
            slug: "any slug",
            isPinned: false,
            isEncrypted: false,
            isEmpty: false,
            subtitle: "any subtitle",
            creationDate: Date(),
            modificationDate: Date(),
            content: "any note content"
        )
    }
    
    static func anyNoteList() -> NoteList {
        NoteList(title: "any note list", slug: "any-note-list", notes: [anyNote()])
    }
    
    static func anyTag() -> Tag {
        Tag(name: "any tag", fullPath: "any-tag", notesCount: 0, children: [], isPinned: false)
    }
    
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
