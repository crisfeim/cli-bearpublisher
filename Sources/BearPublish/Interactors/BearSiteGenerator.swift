// © 2025  Cristian Felipe Patiño Rojas. Created on 13/6/25.

import Foundation

public struct BearSiteGenerator: @unchecked Sendable {
    let site: BearRenderedSite
    let outputURL: URL
    let filesFolderURL: URL
    let imagesFolderURL: URL
    
    public init(site: BearRenderedSite, outputURL: URL, filesFolderURL: URL, imagesFolderURL: URL) {
        self.site = site
        self.outputURL = outputURL
        self.filesFolderURL = filesFolderURL
        self.imagesFolderURL = imagesFolderURL
    }
    
    private func cleanOutputFolder() {
        try? FileManager.default.removeItem(at: outputURL)
    }

     public func execute() async throws {
        cleanOutputFolder()
         async let writeIndex: () = write([site.index])
         async let writeNotes: () = write(site.notes)
         async let writeCategoryLists: () = write(site.listsByCategory)
         async let writeHashtagLists: () = write(site.listsByTag)
         async let writeAssets: () = write(site.assets)
         async let writeMedia: () = copyMedia()
         
        _ = try await [writeIndex, writeNotes, writeCategoryLists, writeHashtagLists, writeAssets, writeMedia]
    }
    
    private func copyMedia() throws {
        try FileManager.default.copyItem(at: filesFolderURL, to: outputURL.appendingPathComponent("files"))
        try FileManager.default.copyItem(at: imagesFolderURL, to: outputURL.appendingPathComponent("images"))
    }
    
    private func write(_ resources: [Resource]) throws {
        try ResourceWriter(resources: resources, outputURL: outputURL).execute()
    }
}
