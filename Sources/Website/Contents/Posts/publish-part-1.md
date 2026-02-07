---
title: Publish 사용하기 part 1
date: 2023-09-12 04:03
tags: Swift, Publish, Web, Theory
image: thumbnail/publish-part-1.svg
description: Swift publish 구조 살펴보기
---

## Publish 구조 살펴보기

기존 처음 Publish 프로젝트를 생성하고, `main.swift` 코드입니다.

```swift
import Foundatio
import Publish
import Plot

// This type acts as the configuration for your website.
struct Example: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://your-website-url.com")!
    var name = "Example"
    var description = "A description of Part"
    var language: Language { .english }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
try Example().publish(withTheme: .foundation)

```

먼저 위 예시의 Example 구조체 부터 보겠습니다.

```swift
struct Example: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://your-website-url.com")!
    var name = "Example"
    var description = "A description of Part"
    var language: Language { .english }
    var imagePath: Path? { nil }
}
```

- `Section ID` : 웹사이트의 Section ID를 나타내는 열거형입니다.
- `itemMetadata` : 사용자가 웹사이트에 대한 Meta data 값을 지정할 수 있는 부분입니다.
- `url` : 웹 사이트를 어떤 URL로 호스팅 될지 지정해주는 부분입니다.
- `name` : 웹 사이트의 이름을 지정해주는 부분입니다.
- `description` : 웹사이트에 대한 설명을 지정해주는 부분입니다.
- `language` : 웹사이트에서 사용하는 주요한 언어를 지정해주는 부분입니다.
- `imagePath` : 웹사이트를 나타내는 이미지의 경로를 지정해주는 부분입니다.

위 예시에는 나와있지 않지만, `favicon` 과 `tagHTMLConfig` 값도 있습니다.

- `favicon` : 웹 브라우저의 주소창에 표시되는 아이콘을 설정 할 수 있습니다.
- `tagHTMLConfig` : 웹 사이트에 대한 Tag HTML을 생성할 때 사용이 됩니다.

Publish에는 기본적으로 `Foundation Theme` 가 제공됩니다.

```swift
try Example().publish(withTheme: .foundation)
```

이 부분에서 Publish 자체에서 제공하는 `Foundation Theme` 을 사용한다는 것을 알 수 있습니다.

커스텀을 시작하기 위해서는 저부분 부터 수정이 필요합니다. <br/><br/>

## 테마 커스텀

여기서부터 좀 publish 사용 난이도가 많이 올라갑니다.

`PublishHTMLFactory.swift` 파일을 생성합니다.

```swift
struct PublishHTMLFactory: HTMLFactory
```

그리고 `HTMLFactory` protocol을 상속 받으면 구조가 생성이됩니다.

처음에는 위 예시 코드에서 있던 Example 구조체를 Site typealias에 입력해주면 됩니다.

```swift
struct PublishHTMLFactory: HTMLFactory {
    typealias Site = Example
}
```

이렇게 해주시면,

```swift
struct PublishHTMLFactory: HTMLFactory {
    typealias Site = Example

    func makeIndexHTML(for index: Publish.Index, context: Publish.PublishingContext<Example>) throws -> Plot.HTML {
        <#code#>
    }

    func makeSectionHTML(for section: Publish.Section<Example>, context: Publish.PublishingContext<Example>) throws -> Plot.HTML {
        <#code#>
    }

    func makeItemHTML(for item: Publish.Item<Example>, context: Publish.PublishingContext<Example>) throws -> Plot.HTML {
        <#code#>
    }

    func makePageHTML(for page: Publish.Page, context: Publish.PublishingContext<Example>) throws -> Plot.HTML {
        <#code#>
    }

    func makeTagListHTML(for page: Publish.TagListPage, context: Publish.PublishingContext<Example>) throws -> Plot.HTML? {
        <#code#>
    }

    func makeTagDetailsHTML(for page: Publish.TagDetailsPage, context: Publish.PublishingContext<Example>) throws -> Plot.HTML? {
        <#code#>
    }
}
```

이런 코드가 생깁니다.

각 메서드에 대한 설명을 하겠습니다.

- `makeIndexHTML` : 웹사이트의 main `index.html` 페이지를 생성합니다.
- `makeSectionHTML` : 웹사이트의 Section 부분에 사용할 `index.html` 페이지를 생성합니다.
- `makeItemHTML` : 웹사이트의 item에 사용할 HTML 파일을 생성합니다.
- `makePageHTML` : 웹사이트의 page에 사용할 HTML 파일을 생성합니다.
- `makeTagListHTML`: Publish에서 제공하는 Tag 부분의 전체 리스트를 제공해주는 화면입니다.
- `makeTagDetailsHTML` : Tag 부분의 상세 내용을 제공해주는 화면입니다.

`HTMLFactory`에서 `<#code#>` 부분 설명이 길어질것 같아서 다음 Post에 작성법에 대해서 상세하게 설명하도록 하겠습니다.

HTMLFactory 내용을 다 입력하고, Theme를 등록하면 됩니다.

```swift
import Publish
import Plot

extension Theme where Site == Example {
    static var publish: Self {
        Theme(htmlFactory: PublishHTMLFactory())
    }
}
```

이런식으로 Example에서 사용 가능한 `publish` 테마를 등록하였습니다.

```swift
try Example().publish(withTheme: .publish)
```

`main.swift` 파일 부분에서
간단하게는 이렇게 사용이 가능합니다.

또는 직접 custom pipeline를 구축하는 방법도 있습니다.

```swift
try Example().publish(using: [
    .optional(.copyResources()),
    .addMarkdownFiles(),
    .generateHTML(withTheme: .publish),
    .generateRSSFeed(including: [.posts]),
    .generateSiteMap()
])
```

`publish(using:)` 메서드에서 pipeline을 하나하나 사용자가 원하는대로 지정할 수 있습니다.

위에서 진행한 내용은 [예시코드](https://github.com/Jihoonahn/Blog-Document/tree/main/Publish/part1) 를 확인할 수 있습니다.

---

이번 글에서는 Publish 커스텀 중에서 구조를 이루는 부분에 대한 글을 적어봤습니다. <br/>
다음 글에서는 publish에서 HTML을 어떻게 작성하는지에 대한 내용을 작성할 예정입니다.
