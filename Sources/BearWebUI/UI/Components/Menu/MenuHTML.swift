//
//  Created by Cristian Felipe Patiño Rojas on 07/09/2023.
//

import Plot

struct MenuHTML: Component, Equatable {
    let menu: [MenuItemViewModel]
    let tags: [MenuItemViewModel]
   
    @ComponentBuilder
    var body: Component {

        Section {
            for item in menu {
                Cell(
                    icon: item.icon,
                    item: item,
                    getRouter: { "/standalone/list/\($0).html" },
                    pushedURL: { "/?list=\($0)" })
            }
        }
        
        Section {
            for tag in tags {
                Cell(
                    icon: .tag,
                    item: tag,
                    getRouter: { "/standalone/tag/\($0).html" },
                    pushedURL: {
                    "/?tag=\($0.replacingOccurrences(of: "&", with: "/"))"
                })
            }
        }
    }
}

