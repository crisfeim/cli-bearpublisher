// © 2025  Cristian Felipe Patiño Rojas. Created on 13/6/25.

import BearDomain
import Foundation

public struct BearPublisher {
    
    public let execute: () async throws -> Void
    
    public init(
        outputURL: URL,
        siteTitle: String,
        indexNotesProvider: @escaping () throws -> [Note],
        notesProvider: @escaping () throws -> [Note],
        tagProvider: @escaping () throws -> [Tag],
        categoryListProvider: @escaping () throws -> [NoteList],
        tagListProvider: @escaping () throws -> [NoteList],
        indexRenderer: BearSiteRenderer.IndexRenderer,
        noteRenderer: BearSiteRenderer.NoteRenderer,
        listByCategoryRenderer: BearSiteRenderer.ListRenderer,
        listByTagRenderer: BearSiteRenderer.ListRenderer,
        filesFolderURL: URL,
        imagesFolderURL: URL,
        assetsProvider: @escaping () -> [Resource]
    ) throws {
        let builder = BearSiteBuilder(
            sitesTitle: siteTitle,
            indexNotesProvider: indexNotesProvider,
            notesProvider: notesProvider,
            listsByCategoryProvider: categoryListProvider,
            listsByTagProvider: tagListProvider,
            tagsProvider: tagProvider
        )
        
        let renderer = BearSiteRenderer(
            site: try builder.execute(),
            indexRenderer: indexRenderer,
            noteRenderer: noteRenderer,
            listsByCategoryRenderer: listByCategoryRenderer,
            listsByTagRenderer: listByTagRenderer,
            assetsProvider: assetsProvider
        )
        
        execute = BearSiteGenerator(
            site: renderer.execute(),
            outputURL: outputURL,
            filesFolderURL: filesFolderURL,
            imagesFolderURL: imagesFolderURL
        ).execute
    }
}
