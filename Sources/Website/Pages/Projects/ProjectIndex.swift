import Foundation
import Web
import Generator

@HTMLBuilder
func projectIndex(projects: [Post]) -> HTML {
    let metadata = SiteMetaData(title: "Projects")
    let sortedProjects = projects.sorted { $0.metadata.date > $1.metadata.date }

    Layout(metadata: metadata) {
        Main {
            Div {
                Div {
                    ComponentGroup(members: sortedProjects.map { post in
                        Link(url: "/projects/\(post.slug)/") {
                            Span {
                                if let image = post.metadata.image {
                                    Image(url: image, description: post.metadata.title)
                                        .class("project-index-icon-img")
                                } else {
                                    Text(String(post.metadata.title.prefix(1)))
                                        .class("project-index-icon-letter")
                                }
                            }
                            .class("project-index-icon-box")
                            Span {
                                Text(post.metadata.title)
                            }
                            .class("project-index-icon-label")
                        }
                        .class("project-index-icon")
                    })
                }
                .class("project-index-grid")
            }
            .class("project-index-wrap")
        }
        .class("min-h-screen")
    }
}
