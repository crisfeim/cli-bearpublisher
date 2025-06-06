//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/09/2023.
//

import Plot

extension Main {
    public struct Hashtag: Component {
        
        let hashtag: String
        let count: Int
        
        public init(hashtag: String, count: Int) {
            self.hashtag = hashtag
            self.count = count
        }
        
        var slug: String { hashtag.replacingOccurrences(of: "/", with: "&") }
        var href: String { "/?tag=\(hashtag)" }
        
        
        var script: String {
        """
        on click set .nav-checkbox.checked to false
        then remove .selected-menu-item from .selected-menu-item
        then add .selected-menu-item to .\(hashtag.safeHash)
        then go to .\(hashtag.safeHash) smoothly
        """
        }
        
       public var body: Component {
            Link(hashtag, url: href)
                .hxGet("/standalone/tag/\(slug)")
                .hxTarget("nav")
                .class("hashtag")
                .hxIndicator(.id(Indicators.spinner))
                .data(named: "count", value: count.description)
                .hyperScript(script)
        }
    }
}
