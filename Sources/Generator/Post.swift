import Foundation
import Logging

public struct PostMetadata: Sendable {
    public let title: String
    public let date: Date
    public let tags: [String]
    public let image: String?
    public let description: String?
    /// 프로젝트 스크린 갤러리용 이미지 URL 배열 (캐러셀 표시, 플랫폼별 없을 때 fallback)
    public let screens: [String]
    /// 플랫폼별 스크린: screenshot/ios, screenshot/ipad, screenshot/macos 폴더 기준
    public let screensIos: [String]
    public let screensIpad: [String]
    public let screensMacos: [String]
    /// 프로젝트 지원 플랫폼 (iOS, iPad, macOS) - 목업 탭 표시용
    public let platforms: [String]

    public init(title: String, date: Date, tags: [String], image: String? = nil, description: String? = nil, screens: [String] = [], screensIos: [String] = [], screensIpad: [String] = [], screensMacos: [String] = [], platforms: [String] = ["iOS"]) {
        self.title = title
        self.date = date
        self.tags = tags
        self.image = image
        self.description = description
        self.screens = screens
        self.screensIos = screensIos
        self.screensIpad = screensIpad
        self.screensMacos = screensMacos
        self.platforms = platforms.isEmpty ? ["iOS"] : platforms
    }

    /// 플랫폼 키(ios/ipad/mac)에 해당하는 스크린 목록. 없으면 screens 사용
    public func screens(forPlatformKey key: String) -> [String] {
        switch key {
        case "ios": return screensIos.isEmpty ? screens : screensIos
        case "ipad": return screensIpad.isEmpty ? screens : screensIpad
        case "mac": return screensMacos.isEmpty ? screens : screensMacos
        default: return screens
        }
    }
}

public struct Post: Sendable {
    public let metadata: PostMetadata
    public let content: String
    public let htmlContent: String
    public let slug: String
    
    public init(metadata: PostMetadata, content: String, htmlContent: String, slug: String) {
        self.metadata = metadata
        self.content = content
        self.htmlContent = htmlContent
        self.slug = slug
    }
    
    public static func from(file: String, content: String) throws -> Post {
        // 새로운 Markdown Parser 사용
        let parser = MarkdownParser()
        let markdown = parser.parse(content)
        
        // slug 생성
        let slug = file
            .replacingOccurrences(of: ".md", with: "")
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        
        // 메타데이터 추출 (새로운 Parser의 metadata 사용)
        let metadata = PostMetadata(
            title: markdown.metadata["title"] ?? "Untitled",
            date: parseDate(from: markdown.metadata["date"]) ?? Date(),
            tags: parseTags(from: markdown.metadata["tags"]),
            image: parseImage(from: markdown.metadata["image"]),
            description: markdown.metadata["description"],
            screens: parseScreens(from: markdown.metadata["screens"]),
            screensIos: parseScreens(from: markdown.metadata["screens_ios"]),
            screensIpad: parseScreens(from: markdown.metadata["screens_ipad"]),
            screensMacos: parseScreens(from: markdown.metadata["screens_macos"]),
            platforms: parsePlatforms(from: markdown.metadata["platforms"])
        )

        return Post(
            metadata: metadata,
            content: content,
            htmlContent: markdown.html, // 새로운 Parser가 HTML 태그를 직접 처리
            slug: slug
        )
    }
    
    // 날짜 파싱 헬퍼 함수
    private static func parseDate(from dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // 다양한 날짜 형식 지원
        let formats = [
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd H:mm",
            "yyyy-MM-dd",
            "yyyy/MM/dd",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))) {
                return date
            }
        }
        
        return nil
    }
    
    // 태그 파싱 헬퍼 함수
    private static func parseTags(from tagsString: String?) -> [String] {
        guard let tagsString = tagsString else { return [] }
        
        // tags: [swift, blog] 또는 tags: swift, blog 형식 지원
        let cleanedValue = tagsString.trimmingCharacters(in: CharacterSet(charactersIn: "[]\"'"))
        return cleanedValue.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    // 이미지 파싱: Contents 프론트매터에 적은 경로를 그대로 사용 (Public 기준 루트 상대 경로)
    private static func parseImage(from imageString: String?) -> String? {
        guard let imageString = imageString else { return nil }
        
        let trimmed = imageString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        // 외부 URL 또는 이미 / 로 시작하는 절대 경로 → 그대로 사용
        if trimmed.hasPrefix("https://") || trimmed.hasPrefix("http://") || trimmed.hasPrefix("/") {
            return trimmed
        }
        // 상대 경로 → Public 루트 기준으로 / 경로 (예: thumbnail/foo.svg → /thumbnail/foo.svg, app/daysquare/Icon.svg → /app/daysquare/Icon.svg)
        return "/" + trimmed
    }

    /// screens: "url1, url2, url3" 형태 파싱, 각 경로는 parseImage 규칙으로 정규화
    private static func parseScreens(from screensString: String?) -> [String] {
        guard let s = screensString else { return [] }
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return trimmed.components(separatedBy: ",").compactMap { part in
            let p = part.trimmingCharacters(in: .whitespaces)
            return parseImage(from: p.isEmpty ? nil : p)
        }
    }

    /// platforms: "iOS, iPad, macOS" 형태 파싱
    private static func parsePlatforms(from platformsString: String?) -> [String] {
        guard let s = platformsString else { return ["iOS"] }
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ["iOS"] }
        let list = trimmed.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return list.isEmpty ? ["iOS"] : list
    }
}
