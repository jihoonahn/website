import Foundation
import Web
import Generator

struct PostLayout: HTMLConvertable {
    let post: Post
    let allPosts: [Post]

    func build() -> HTML {
        ContentDetailLayout(
            post: post,
            allPosts: allPosts,
            backPath: "/posts",
            bottomNavigation: PostNavigation(currentPost: post, allPosts: allPosts)
        ).build()
    }
}
