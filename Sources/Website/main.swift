import Foundation
import Generator
import Web

let arguments = CommandLine.arguments

// Posts: Sources/Website/Contents/Posts/*.md → /posts/
var contentPosts = Content(path: "Sources/Website/Contents/Posts", postsPerPage: postsPerPage) { post, allPosts in
    PostLayout(post: post, allPosts: allPosts)
        .build()
}
let contentPostPages = try contentPosts.load()
let allPosts = contentPosts.posts

// Projects: Sources/Website/Contents/Projects/*.md → /projects/
var contentProjects = Content(path: "Sources/Website/Contents/Projects", postsPerPage: 10) { post, allProjects in
    ProjectLayout(post: post, allPosts: allProjects)
        .build()
}
let contentProjectPages = try contentProjects.load()
let allProjects = contentProjects.posts

var paginationPages: [Page] = []
let postsPerPage = 10
let totalPages = max(1, Int(ceil(Double(allPosts.count) / Double(postsPerPage))))

for pageNumber in 1...totalPages {
    let pageHTML = postIndex(posts: allPosts, page: pageNumber, postsPerPage: postsPerPage)
    let pagePath = pageNumber == 1 ? "posts" : "posts/page/\(pageNumber)"
    let pageName = pageNumber == 1 ? "Posts" : "Posts Page \(pageNumber)"

    paginationPages.append(Page(
        name: pageName,
        path: pagePath,
        html: pageHTML,
        children: pageNumber == 1 ? contentPostPages : [
            Page(
                name: pageName,
                path: "index.html",
                html: pageHTML
            )
        ]
    ))
}

let projectsPage = Page(
    name: "Projects",
    path: "projects",
    html: projectIndex(projects: allProjects),
    children: contentProjectPages
)

let pages = [
    Page(
        name: "Index",
        path: "index.html",
        html: index()
    ),
    Page(
        name: "Page Not Found",
        path: "404.html",
        html: error()
    )
] + paginationPages + [
    projectsPage,
    Page(
        name: "About",
        path: "about",
        children: [
            Page(
                name: "About Index",
                path: "index.html",
                html: about()
            )
        ]
    )
]

do {
    let generator = Generator(pages: pages, posts: allPosts)
    try generator.generate()
    
    if arguments.contains("preview") || arguments.contains("--preview") {
        print("\n🌐 Starting preview server...")
        
        let previewPort = 8000
        killProcessOnPort(previewPort)
        
        print("📍 Open http://localhost:\(previewPort) in your browser")
        print("⌨️  Press Ctrl+C to stop the server\n")
        
        // Python 서버를 백그라운드에서 실행
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = ["-m", "http.server", "\(previewPort)", "--directory", "dist"]
        
        do {
            try process.run()
            print("✅ Preview server is running at http://localhost:\(previewPort)")
            print("   Serving files from: dist/\n")
            
            // 서버가 계속 실행되도록 대기
            process.waitUntilExit()
        } catch {
            print("❌ Failed to start preview server: \(error.localizedDescription)")
            print("💡 Make sure Python 3 is installed and accessible")
        }
    } else {
        print("\n💡 Tip: Run 'swift run Website preview' to start a local server")
    }
    
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}

func killProcessOnPort(_ port: Int) {
    let killProcess = Process()
    killProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    killProcess.arguments = ["sh", "-c", "lsof -ti :\(port) | xargs kill -9 2>/dev/null || true"]
    killProcess.standardOutput = FileHandle.nullDevice
    killProcess.standardError = FileHandle.nullDevice
    try? killProcess.run()
    killProcess.waitUntilExit()
}
