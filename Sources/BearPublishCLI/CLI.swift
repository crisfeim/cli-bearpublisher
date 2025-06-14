// © 2025  Cristian Felipe Patiño Rojas. Created on 3/6/25.

import ArgumentParser
import Foundation
import BearPublish

@main
struct BearPublisherCLI: AsyncParsableCommand {
    
    @Option(name: .shortAndLong, help: "The Bear sqlite database path") var dbPath: String = "/Users/\(NSUserName())/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite"
    
    @Option(name:.shortAndLong) var imagesFolderPath: String = "/Users/\(NSUserName())/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/Local Files/Note Files"
    @Option(name:.shortAndLong) var filesFolderPath: String = "/Users/\(NSUserName())/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/Local Files/Note Files"
    @Option(name: .shortAndLong, help: "The site's build path") var output: String = "dist"
    @Option(name: .shortAndLong, help: "The site's title") var title: String = "Home"
    
    func run() async throws {
        let imagesFolderPath: String = "/Users/\(NSUserName())/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/Local Files/Note Images"
        let outputURL = URL(fileURLWithPath: output)
        let imagesFolder = URL(fileURLWithPath: imagesFolderPath)
        let filesFolder = URL(fileURLWithPath: filesFolderPath)
        
        let publisher = try BearPublisherComposer.make(
            dbPath: dbPath,
            outputURL: outputURL,
            filesFolderURL: filesFolder,
            imagesFolderURL: imagesFolder,
            siteTitle: title
        )
        try await publisher.execute()
    }
}
