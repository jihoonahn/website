import Foundation
import Logging
import File
import Command
import Web

public struct Page: Sendable {
    public let name: String
    public let path: String
    public let html: Web.HTML?
    public let children: [Page]?
    
    public init(name: String, path: String, html: Web.HTML) {
        self.name = name
        self.path = path
        self.html = html
        self.children = nil
    }
    
    public init(name: String, path: String, children: [Page]) {
        self.name = name
        self.path = path
        self.html = nil
        self.children = children
    }
    
    public init(name: String, path: String, html: Web.HTML, children: [Page]) {
        self.name = name
        self.path = path
        self.html = html
        self.children = children
    }
}

public final class Generator: Sendable {
    let distPath = "dist"
    let publicPath = "Public"
    
    private let pages: [Page]
    private let posts: [Post]
    
    public init(pages: [Page], posts: [Post] = []) {
        self.pages = pages
        self.posts = posts
    }

    public func generate() throws {
        logger.info("Start Generate Website...")
        
        try setupDistFolder()
        try buildTailwindCSS()
        try copyPublicFiles()
        try generatePages()
        try generateRSSFeed()
        try generateSitemap()
        
        logger.info("✅ Website generated successfully!")
    }
    
    private func setupDistFolder() throws {
        logger.info("Setting up dist folder...")

        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: distPath) {
            try fileManager.removeItem(atPath: distPath)
        }

        try fileManager.createDirectory(atPath: distPath, withIntermediateDirectories: true)
        
        logger.info("✅ Dist folder setup complete")
    }
    
    private func buildTailwindCSS() throws {
        logger.info("Building Tailwind CSS...")

        @Command(\.bash) var bash
        
        let result = bash.run(["npm", "run", "css:build"])
        switch result {
        case .success(_, _):
            logger.info("✅ Tailwind CSS built successfully")
        case .failure(_, let error):
            logger.warning("⚠️  Tailwind build error: \(error)")
            logger.info("ℹ️  Continuing without Tailwind CSS...")
        }
    }
    
    private func copyPublicFiles() throws {
        logger.info("Copying public files...")
        
        let publicFolder = try? Folder(path: Path(publicPath))
        guard publicFolder != nil else {
            logger.info("ℹ️  No Public folder found, skipping")
            return
        }
        
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: publicPath)
        var copiedCount = 0
        
        for item in contents where !item.hasPrefix(".") {
            let sourcePath = "\(publicPath)/\(item)"
            let destPath = "\(distPath)/\(item)"
            
            // 파일이 이미 존재하면 덮어쓰기
            if fileManager.fileExists(atPath: destPath) {
                try fileManager.removeItem(atPath: destPath)
            }
            
            try fileManager.copyItem(atPath: sourcePath, toPath: destPath)
            copiedCount += 1
            logger.info("  ✓ Copied: \(item)")
        }
        
        logger.info("✅ Copied \(copiedCount) file(s) from Public folder")
    }
    
    
    private func generatePages() throws {
        logger.info("Generating static pages...")

        for page in pages {
            try generatePage(page, basePath: distPath)
        }

        logger.info("✅ All pages generated")
    }
    
    private func generateRSSFeed() throws {
        logger.info("Generating RSS feed...")
        
        if !posts.isEmpty {
            let siteMetadata = SiteMetaData(
                title: "Swift Blog",
                description: "Swift 개발과 관련된 블로그 포스트들",
                url: "https://jihoon.me"
            )
            
            let rssGenerator = RSSGenerator(posts: posts, siteMetadata: siteMetadata)
            let rssContent = rssGenerator.generateRSS()
            
            let rssPath = Path("\(distPath)/feed.rss")
            let file = try File(path: rssPath)
            try file.write(rssContent)
            
            logger.info("  ✓ Generated: RSS Feed -> \(distPath)/feed.rss")
        } else {
            logger.info("ℹ️  No posts found, skipping RSS feed generation")
        }
        
        logger.info("✅ RSS feed generation complete")
    }
    
    private func generateSitemap() throws {
        logger.info("Generating sitemap...")
        
        let siteMetadata = SiteMetaData(
            title: "Swift Blog",
            description: "Swift 개발과 관련된 블로그 포스트들",
            url: "https://jihoon.me"
        )
        
        let sitemapGenerator = SitemapGenerator(pages: pages, posts: posts, siteMetadata: siteMetadata)
        let sitemapContent = sitemapGenerator.generateSitemap()
        
        let sitemapPath = Path("\(distPath)/sitemap.xml")
        let file = try File(path: sitemapPath)
        try file.write(sitemapContent)
        
        logger.info("  ✓ Generated: Sitemap -> \(distPath)/sitemap.xml")
        logger.info("✅ Sitemap generation complete")
    }
    
    private func generatePage(_ page: Page, basePath: String) throws {
        let fullPath = "\(basePath)/\(page.path)"
        
        let fileManager = FileManager.default
        
        if let children = page.children {
            if !fileManager.fileExists(atPath: fullPath) {
                try fileManager.createDirectory(atPath: fullPath, withIntermediateDirectories: true)
            }
            
            if let html = page.html {
                let indexPath = Path("\(fullPath)/index.html")
                let file = try File(path: indexPath)
                try file.write(html.render())
                logger.info("  ✓ Generated: \(page.name) -> \(fullPath)/index.html")
            }
            
            for child in children {
                try generatePage(child, basePath: fullPath)
            }
        } else {
            if let html = page.html {
                let pagePath = Path(fullPath)
                let file = try File(path: pagePath)
                try file.write(html.render())
                logger.info("  ✓ Generated: \(page.name) -> \(fullPath)")
            }
        }
    }
}
