---
title: Publish 사용하기 part 2
date: 2023-10-26 14:48
tags: Swift, Publish, Web, Theory
image: thumbnail/publish-part-2.svg
description: Swift publish 커스텀하기
---

## Publish 구조 작성하기

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

이전 포스트에서 만든 `PublishHTMLFactory` 부분 부터 보도록 하겠습니다.

Publish에서 HTML 로 구조를 작성하기 위해서, [`Plot`](https://github.com/JohnSundell/Plot)이라는 JohnSundell이 만든 라이브러리를 사용합니다.

기존에는

```swift
let html = HTML(
    .head(
        .title("My website"),
        .stylesheet("styles.css")
    ),
    .body(
        .div(
            .h1("My website"),
            .p("Writing HTML in Swift is pretty great!")
        )
    )
)
```

이런 방식으로 작성했지만, Plot이 업데이트 되면서, Component 프로토콜을 사용해서 Component 요소들을 SwiftUI와 유사한 방식으로 작성할 수 있습니다.

```swift
struct NewsArticle: Component {
    var imagePath: String
    var title: String
    var description: String

    var body: Component {
        Article {
            Image(url: imagePath, description: "Header image")
            H1(title)
            Span(description).class("description")
        }
        .class("news")
    }
}
```

이런 방식으로 말이죠

간단하게 알아 봤으니 한번 Publish에서 사용해보겠습니다.
먼저 가장 먼저 보일 부분인 Index 부분을 커스텀해보겠습니다.

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    <#code#>
}
```

먼저 `HTML`이라는 구조체를 `makeIndexHTML` 메서드에 추가해줍니다.

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    /// HTML 구조체 내에 node를 추가할 수 있는 형태
    HTML()

    /// HTML 구조체에 들어갈 head 부분이랑 body 부분을 init에서 분리해주는 형태
    HTML(head: [], body: {})
}
```

위 두가지 HTML 에서 하나를 선택해주시면 됩니다.
저는 위 방식으로 진행하도록 하겠습니다.

먼저 사용할 언어를 선택해줍니다.

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language) /// <html lang="$(main에서 설정한 언어)">
    )
}
```

Head에 필요한 정보들을 넣어줍니다. 저는 publish에서 제공해주는 head static 메서드를 통해서 구성해주도록 하겠습니다.

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: index, on: context.site)
    )
}
```

빌드를 돌리게 되면

<img width=80% src="https://github.com/jihoonahn/blog/assets/68891494/af1b26e6-2045-4775-bcae-877912ca7b84"></img>

이런식으로 Head 부분이 쉽게 구축이 된것을 확인 할 수 있습니다.
publish에서 제공하는 head 메서드는 저희가 따로 node로 넣어줄 필요없이 가장 자주 사용되는것들로 구성해 줍니다.

하지만 웹에서는 /style.css에러가 발생합니다. 이 부분은

```swift
static func head<T: Website>(
    for location: Location,
    on site: T,
    titleSeparator: String = " | ",
    stylesheetPaths: [Path] = ["/styles.css"],
    rssFeedPath: Path? = .defaultForRSSFeed,
    rssFeedTitle: String? = nil
) -> Node {}
```

head static 메서드가 선언된 부분을 보면 알 수 있습니다. <br/>
`stylesheetPath`에 내용이 들어가지 않기 때문에, 자동으로 style.css 부분을 넣어줘서, 현재는 style.css 파일이 없기 때문에 에러가 발생하는 것입니다.

```swift
.head(for: index, on: context.site, stylesheetPaths: [])
```

그래서 아직 stylesheet 넣지 않을것이라면 이런식으로 빈 배열로 값을 넣어주면 에러가 발생하지 않습니다.

그 다음은 Body 입니다. <br/>
Body 같은 경우도 node로 추가하는 방법도 있지만, 앞에서 말했던 Component를 사용해봅시다.

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: index, on: context.site),
        .body {
            // Body Code
        }
    )
}
```

## Component 사용법

Component를 사용하기 위해서는 `Component` 라는 프로토콜을 상속 받아줍니다.

```swift
struct ComponentName: Component
```

이렇게 상속을 받아주면

```swift
struct ComponentName: Component {
    var body: Component {}
}
```

이런식으로 SwiftUI와 비슷한 스타일로 Component body 부분에서 기존에 사용하던 `Node` 또는 다른 `Component`를 이곳에 넣을 수 있습니다.

```swift
struct ComponentName: Component {
    var body: Component {
        Div {
            ...
        }
        .class("site-div")
    }
}
```

이런식으로 Component를 제작할 수 있습니다.

현재 Plot에서 제공하고 있는 Component에서 사용할 수 있는 [`HTMLComponent`](https://github.com/JohnSundell/Plot/blob/master/Sources/Plot/API/HTMLComponents.swift) 입니다.

```swift
/// A container component that's rendered using the `<article>` element.
public typealias Article = ElementComponent<ElementDefinitions.Article>
/// A container component that's rendered using the `<aside>` element.
public typealias Aside = ElementComponent<ElementDefinitions.Aside>
/// A container component that's rendered using the `<button>` element.
public typealias Button = ElementComponent<ElementDefinitions.Button>
/// A container component that's rendered using the `<div>` element.
public typealias Details = ElementComponent<ElementDefinitions.Details>
/// A container component that's rendered using the `<div>` element.
public typealias Div = ElementComponent<ElementDefinitions.Div>
/// A container component that's rendered using the `<fieldset>` element.
public typealias FieldSet = ElementComponent<ElementDefinitions.FieldSet>
/// A container component that's rendered using the `<footer>` element.
public typealias Footer = ElementComponent<ElementDefinitions.Footer>
/// A container component that's rendered using the `<h1>` element.
public typealias H1 = ElementComponent<ElementDefinitions.H1>
/// A container component that's rendered using the `<h2>` element.
public typealias H2 = ElementComponent<ElementDefinitions.H2>
/// A container component that's rendered using the `<h3>` element.
public typealias H3 = ElementComponent<ElementDefinitions.H3>
/// A container component that's rendered using the `<h4>` element.
public typealias H4 = ElementComponent<ElementDefinitions.H4>
/// A container component that's rendered using the `<h5>` element.
public typealias H5 = ElementComponent<ElementDefinitions.H5>
/// A container component that's rendered using the `<h6>` element.
public typealias H6 = ElementComponent<ElementDefinitions.H6>
/// A container component that's rendered using the `<header>` element.
public typealias Header = ElementComponent<ElementDefinitions.Header>
/// A container component that's rendered using the `<li>` element.
public typealias ListItem = ElementComponent<ElementDefinitions.ListItem>
/// A container component that's rendered using the `<main>` element.
public typealias Main = ElementComponent<ElementDefinitions.Main>
/// A container component that's rendered using the `<nav>` element.
public typealias Navigation = ElementComponent<ElementDefinitions.Navigation>
/// A container component that's rendered using the `<p>` element.
public typealias Paragraph = ElementComponent<ElementDefinitions.Paragraph>
/// A container component that's rendered using the `<span>` element.
public typealias Span = ElementComponent<ElementDefinitions.Span>
/// A container component that's rendered using the `<summary>` element.
public typealias Summary = ElementComponent<ElementDefinitions.Summary>
/// A container component that's rendered using the `<caption>` element.
public typealias TableCaption = ElementComponent<ElementDefinitions.TableCaption>
/// A container component that's rendered using the `<td>` element.
public typealias TableCell = ElementComponent<ElementDefinitions.TableCell>
/// A container component that's rendered using the `<th>` element.
public typealias TableHeaderCell = ElementComponent<ElementDefinitions.TableHeaderCell>
```

이부분을 통해서 Component를 제작하실때 필요한 HTML Element를 사용할 수 있습니다.

Component가 잘 제작이 됬다면

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: index, on: context.site),
        .body {
            HeaderComponent() // 제작한 Component
            PostsLayout()     // 제작한 Component
            FooterComponent() // 제작한 Component
        }
    )
}
```

이런식으로 body에 넣어서 추가가 가능하죠.
간단하게 Component를 추가하는 방법에 대해서 알아보았습니다.

그럼 한번 제대로된 Publish 프로젝트 하나를 만들어보면서 어떻게 사용해야하는지 감을 잡아봅시다.

## Example

간단하게 디자인 한 이미지를 토대로 개발해보도록 하겠습니다.

<img width = 100% src = "https://github.com/jihoonahn/blog/assets/68891494/6155676b-0bc2-4661-825d-ad521f4b5df1"></img>

먼저 기존에 만들어둔 Example에서 진행을 해보겠습니다.

```
- Components
- Layouts
- Pages
- Utils
```

Website를 만들때 이렇게 3가지로 폴더를 분리하였습니다.

- `Components`: `Components`는 `Header` 와 `Footer` 같은 페이지에 필요한 컴포넌트의 집합
- `Layouts`: `Layouts` 은 page template와 같은 재사용 가능한 UI 구조를 제공합니다.
- `Pages`: `Pages`는 웹사이트의 모든 페이지에 대한 레이아웃을 처리합니다.
- `Utils`: 코드에 추가적으로 필요한 작업이나 확장 관련된 내용이 포함이 됩니다.

예시 프로젝트의 폴더에 대한 정보를 봤으니

일단 모든 페이지에서 공통적으로 사용되는 `Header`와 `Footer`부터 작업해보도록 하겠습니다.

먼저 Header입니다.

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/06bb2285-673e-48d7-a0b3-40270bcdabf3"></img>

Header부분을 보면
이런식으로 구성되어 있습니다. <br/>
Logo를 눌렀을때 index 페이지로 이동하게 하고, section을 눌렀을 때 각각 section에 맞는 페이지로 이동을하는 기능이 필요합니다.

```swift
struct HeaderComponent: Component
```

먼저 Components 부분에서 HeaderComponent라는 것을 추가하고 Component 프로토콜을 상속 받게 되면

```swift
import Publish
import Plot

struct HeaderComponent: Component {
    var body: Component {}
}
```

이런식으로 body가 자동으로 만들어지고 저희는 site에 어떤 Section이 있고 사용자가 클릭한 section에 대한 정보를 가져와야 하기 때문에

```swift
var context: PublishingContext<Example>
```

`Publish` 에 있는 PublishingContext를 통해서 정보를 가져올 수 있게 합니다.

```swift
struct HeaderComponent: Component {
    var context: PublishingContext<Example>

    var body: Component {
        Header {
            Link("Blog", url: "/")
                .class("header-logo")
            Div {
                Navigation {
                    List(Example.SectionID.allCases) { sectionID in
                        Link(
                            context.sections[sectionID].title,
                            url: context.sections[sectionID].path.absoluteString
                        )
                        .class("header-nav-menu-link")
                    }
                }
                .class("header-nav")
            }
            .class("content")
        }
        .class("site-header")
    }
}
```

`Link` 같은 경우는 Html에서 `<a>` 태그를 담당합니다. Blog 라는 Text를 누르면 기존 타 사이트와 마찬가지로 index 페이지로 이동하도록 만들었고

`Section` 부분은 List를 사용해서 저희가 `main.swift` 에 등록한 Section들을 모두 보여주게 만들었습니다.

그리고 기존 디자인에 맞춰서 코드를 넣어주고 `styles.css` 에서 style 관련 css 코드를 넣어주었습니다.

그렇게 하면 이렇게 디자인 했던 것처럼 결과 값을 받아보실 수 있습니다.

<img src="https://github.com/jihoonahn/blog/assets/68891494/945b5880-100d-4439-ae26-b57c87cea2da"></img>

그 다음은 Footer 입니다.

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/20cb53bc-5a73-4155-a171-39d6bd79711d"></img>

굉장하게 간단한 Footer 입니다.

Text로 구성하고 싶고, `Copyright Link` 부분을 누르면 저의 깃허브로 이동하도록 만들고 싶네요.

```swift
struct FooterComponent: Component {
    var body: Component {
        Footer {
            // code
        }
        .class("site-footer")
    }
}
```

Component를 선언후에 Footer를 넣어주고

```swift
struct FooterComponent: Component {
    var body: Component {
        Footer {
            Paragraph("Made with Publish")
            Paragraph {
                Text("Copyright © ")
                Link("Jihoonahn", url: "https://github.com/jihoonahn")
            }
            .class("copyright")
        }
        .class("site-footer")
    }
}
```

이렇게 간단하게 구축했습니다.

`Paragraph` 가 HTML에서는 `<p>` 태그의 역할을 하고, 저희는 copyright 부분중에 Jihoonahn 이라고 적힌 부분을 눌렀을 때 깃허브로 이동시키고 싶으니 이렇게 `Paragraph` 내부에 `Text` 와 `Link` 를 넣어줍니다.

이렇게 되면 `"Copyright © "` 부분을 눌렀을 때는 링크로 이동하지 않지만, `Jihoonahn` 을 눌렀을때만 이동을 하게 됩니다.

마찬가지로 기존 디자인에 맞춰서 코드를 넣어주고 `styles.css` 에서 style 관련 css 코드를 넣어주었습니다.

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/a7fd064d-7048-4151-9acf-7712b2474bbf"></img>

간단하게 Header 와 Footer Component를 만들었고 한번 이제 페이지를 구축해볼까요?

### Index

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: index, on: context.site, stylesheetPaths: []),
        .body {
            // Index Page
        }
    )
}
```

기존의 `HTMLFactory` 에서 index부분 부터 한번 작업을 해보도록하겠습니다.

Index의 Page부분을 만들기 위해서 `Pages` 폴더에서 `IndexPage.swift` 파일을 만들었습니다.

```swift
struct IndexPage: Component {
    var context: PublishingContext<Example>

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            FooterComponent()
        }
    }
}
```

여러개의 Component가 동시에 들어가기 때문에 `ComponentGroup` 로 묶어 두고 기존에 만들어둔 Header와 Footer을 넣어둡니다.

그리고 `Layouts` 폴더에 `PostsLayout.swift` 란 파일을 만들어서

```swift
struct PostsLayout: Component
```

`PostsLayout` 이라는 Component를 만들고

다시 IndexPage로 돌아가서

```swift
struct IndexPage: Component {
    var context: PublishingContext<Example>

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            PostsLayout()
            FooterComponent()
        }
    }
}
```

이런식으로 `PostsLayout` 도 추가로 넣어둡니다.

그리고 `IndexPage` 를 `HTMLFactory` 의 `makeIndexHTML` method에 넣어줍니다.

```swift
func makeIndexHTML(for index: Index, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: index, on: context.site),
        .body {
            IndexPage(context: context)
        }
    )
}
```

그럼 이제 Index 부분을 완성하기 위해서 `PostsLayout` 부분을 채워볼까요?

Posts 같은 경우

<img src="https://github.com/jihoonahn/blog/assets/68891494/30bdd5a9-8e18-4ffd-9817-b7a2af4ed663"></img>

이 부분이 반복됩니다. 전체가 링크로 감싸져 있는 형태이죠.

시작하기 전에 Publish에서 확장이 되어 있지 않는 Component가 몇가지 있습니다. 그중에 PostsLayout에서 사용하고 싶은 `section` 도 아직은 존재하지 않죠

그러므로 만약 없는 Component들은 어떻게 해야하는지 보도록 하겠습니다.
`Utils/Plot/ElementDefinitions.swift` 파일을 보시면 됩니다.

`Publish` 의 HTML 부분을 담당하는 `Plot` 에서 `Section` 이 `Node`에서는 `Component` 타입으로 존재하지 않는것이기 때문에

```swift
extension ElementDefinitions {
    enum Section: ElementDefinition { public static var wrapper = Node.section }
}

typealias Section = ElementComponent<ElementDefinitions.Section>
```

이런 방식으로 기존의 Plot의 `ElementDefinitions` 부분을 참고하여 확장하시면 됩니다.

이제 `PostsLayout` 을 제작해보겠습니다.

```swift
let items: [Item<Example>]
```

- `items` 는 Post들을 가져오는 역할을 합니다.

이 프로퍼티를 추가해주고 `IndexPage.swift` 를 수정해줍니다.

```swift
struct IndexPage: Component {
    var context: PublishingContext<Example>

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            PostsLayout(items: context.allItems(sortedBy: \.date))
            FooterComponent()
        }
    }
}
```

이런 식으로 Context의 모든 Item을 들고오면서 날짜 순서대로 정렬이 되도록 해뒀습니다.

다시 `PostsLayout` 부분으로 돌아가서

```swift
struct PostsLayout: Component {
    let items: [Item<Example>]

    var body: Component {
        Section {
            Div {
                List(items) { item in
                    Article {
                        Link(url: item.path.absoluteString) {
                            Paragraph(item.tags.map{ $0.string }.joined(separator: ", "))
                                .class("posts-tag")
                            H3(item.title)
                                .class("posts-title")
                            Paragraph(item.description)
                                .class("posts-description")
                        }
                        .class("posts-link")
                    }
                    .class("posts-article")
                }
                .class("posts-list")
            }
            .class("site-posts-inner")
        }
        .class("site-posts")
    }
}
```

`items` 값을 `List(<ul>)`로 보여줄 수 있도록 제작하고 `styles.css` 에 css 코드를 넣어주면 됩니다.

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/8db4b824-1c1e-48a0-a5f2-66e761a9ccf0"></img>

실행을 해보면 위 Index 디자인한것과 같은 결과물을 얻을 수 있습니다.

그 다음으로는 Section 부분을 처리해보겠습니다.

### Section

```swift
func makeSectionHTML(for section: Publish.Section<Example>, context: Publish.PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: section, on: context.site),
        .body {
            // Section Code
        }
    )
}
```

`HTMLFactory` 부분에서 `makeSectionHTML` 메서드에 Section 코드를 추가하면 됩니다.

```swift
struct SectionPage: Component
```

`Pages/Section/SectionPage.swift` 파일에 SectionPage라는 Component를 만들고

```swift
var section: Publish.Section<Example>
var context: PublishingContext<Example>
```

Example의 `section` 과 `Context` 를 가져와 줍니다.

```swift
struct SectionPage: Component {
    var section: Publish.Section<Example>
    var context: PublishingContext<Example>

    var body: Component {
        switch section.path.string {
        case Example.SectionID.blog.rawValue:
            return IndexPage(context: context)
        case Example.SectionID.about.rawValue:
            // About Page
        default: return Div()
        }
    }
}
```

이렇게 section의 path가 `blog`이면 `IndexPage`를 보여주게 하고 `about` 이라면 `AboutPage`를 보여주게 만듭니다.

```swift
struct AboutPage: Component {
    var context: PublishingContext<Example>

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            Div {
                Image("/images/AboutPageImage.svg")
                H2("Publish Example")
                Paragraph("Jihoonahn’s Blog Example")
            }
            .class("site-about")
            FooterComponent()
        }
    }
}
```

그리고 `SectionPage`에 넣어둘 `AboutPage`가 필요하기 때문에 간단하게 제작하고,

```swift
struct SectionPage: Component {
    var section: Publish.Section<Example>
    var context: PublishingContext<Example>

    var body: Component {
        switch section.path.string {
        case Example.SectionID.blog.rawValue:
            return IndexPage(context: context)
        case Example.SectionID.about.rawValue:
            return AboutPage(context: context)
        default: return Div()
        }
    }
}
```

이렇게 넣어두면

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/04a19586-afba-485e-8304-10071c65af01"></img>

이렇게 Header에 있는 `About` Section을 누르게 되면 `AboutPage` 로 이동이 되게 만들 수 있습니다.

### Post

그 다음으로는 Index에서 Post중 하나를 눌렀을 때 그 Post의 내용을 볼 수 있도록 만들겠습니다.

```swift
func makeItemHTML(for item: Item<Example>, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: item, on: context.site),
        .body {
            /// Post
        }
    )
}
```

이곳에 `post` 들의 item을 가져올 수 있습니다.

```swift
struct PostLayout: Component
```

`Layouts/PostLayout.swift` 에서 위 Index와 비슷하게 `PostLayout` 이라는 Component를 만들어주겠습니다.

그리고 `PostLayout` 부분에서 Item 내용을 가져오기 위해서

```swift
var item: Item<Example>
var context: PublishingContext<Example>
```

- `item` 프로퍼티를 통해서 가져올 수 있도록 하였습니다.
- `context`는 tag의 url을 가져오기 위해서 사용하였습니다.

```swift
struct PostLayout: Component {
    var item: Item<Example>
    var context: PublishingContext<Example>

    var body: Component {
        Section {
            Article {
                Div {
                    for tag in item.tags {
                        Link(tag.string, url: context.site.url(for: tag))
                            .class("post-tag")
                    }
                    H2(item.title)
                        .class("post-title")
                    Paragraph(DateFormatter.time.string(from: item.date))
                        .class("post-date")
                }
                .class("site-post-header")
                Div {
                    Div {
                        Node.contentBody(item.body)
                    }
                }
                .class("site-post-content")
            }
            .class("site-post-article")
        }
        .class("site-post")
    }
}
```

디자인 대로 구축한 `PostLayout` 코드입니다.

```swift
for tag in item.tags {
    Link(tag.string, url: context.site.url(for: tag))
        .class("post-tag")
}
```

item에 있는 tag들을 가져와서 눌렀을때 Tag에 관련된 Post를 찾을 수 있는 페이지로 이동시킵니다.

```swift
Node.contentBody(item.body)
```

그리고 저희가 `Content` 파일에 markdown으로 추가한 내용을 볼 수 있도록 `Node` 의 `contentBody` 메서드를 사용해주시면 됩니다.

```swift
struct PostPage: Component {
    var item: Item<Example>
    var context: PublishingContext<Example>

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            PostLayout(item: item, context: context)
            FooterComponent()
        }
    }
}
```

그리고 `PostLayout`을 만들었으니, `PostPage` 에 `PostLayout`을 가져와주시면 됩니다.

```swift
func makeItemHTML(for item: Item<Example>, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: item, on: context.site),
        .body {
            PostPage(item: item, context: context)
        }
    )
}
```

다시 `HTMLFactory` 부분으로 돌아가서 `PostPage` 부분을 body에 넣어주시면

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/1043641c-3e1e-4bec-bc31-6612f6a0bfdf"></img>

이렇게 Markdown에 있는 Post가 잘 작동하는 것을 확인할 수 있습니다.

### Page

`makePageHTML` 부분은 특별하게 예시에서는 사용하고 있지 않기 때문에

```swift
func makePageHTML(for page: Page, context: PublishingContext<Example>) throws -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: page, on: context.site),
        .body {
            page.body
        }
    )
}
```

`page.body` 만 보이게 해뒀습니다.

### Tag List

그 다음은 `TagList` 입니다. Post에 있는 모든 Tag들을 한번에 가져와서 볼 수 있게 하는 역할을 합니다.

```swift
func makeTagListHTML(for page: Publish.TagListPage, context: PublishingContext<Example>) throws -> HTML? {
    HTML(
        .lang(context.site.language),
        .head(for: page, on: context.site),
        .body {
            // TagList Code
        }
    )
}
```

`HTMLFactory` 부분에서 `makeTagListHTML` 에서 처리할 수 있습니다.

```swift
struct TagListPage: Component
```

먼저 `TagListPage` 에서 마찬가지로 Component를 생성하고

```swift
let tags: Set<Tag>
```

`TagListPage`에서는 `Publish.TagListPage`에 있는 모든 태그를 들고 올 수 있게 `Set<Tag>` 타입을 사용합니다.

```swift
struct TagListPage: Component {
    let tags: [Tag]
    let context: PublishingContext<Example>

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            List(tags) { tag in
                ListItem {
                    Link(tag.string, url: context.site.url(for: tag))
                }
                .class("site-tag")
            }
            .class("site-tagList")
            FooterComponent()
        }
    }
}
```

그리고 `tags` 를 List에 넣어서 보여주고 `styles.css` 에서 간단한 css 코드만 추가해주었습니다.

```swift
func makeTagListHTML(for page: Publish.TagListPage, context: PublishingContext<Example>) throws -> HTML? {
    HTML(
        .lang(context.site.language),
        .head(for: page, on: context.site),
        .body {
            TagListPage(tags: page.tags, context: context)
        }
    )
}
```

다시 `HTMLFactory` 코드로 돌아와서 `TagListPage`를 넣어줍니다.

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/f069ee2d-da19-4d8a-a44e-9e1dd386174b"></img>

이렇게 디자인과 같은 TagList 페이지를 얻을 수 있습니다.

### TagDetail

마지막 `TagDetail` 부분입니다. 지정된 tag를 눌렀을 때 이 tag를 가지고 있는 post를 보여주는 역할을 합니다.

```swift
func makeTagDetailsHTML(for page: Publish.TagDetailsPage, context: PublishingContext<Example>) throws -> HTML? {
    HTML(
        .lang(context.site.language),
        .head(for: page, on: context.site),
        .body {
            // Tag Details Code
        }
    )
}
```

`HTMLFactory`에서 마지막 하나 남은 메서드인 `makeTagDetailsHTML` 에서 작업을 하실 수 있습니다.

```swift
struct TagDetailPage: Component
```

`TagDetailPage`라는 Component를 선언하고

```swift
let items: [Item<Example>]
let selectedTag: Tag
```

- `items`: Tag에 포함된 post들을 가져옵니다.
- `selectedTag`: 선택된 Tag의 정보를 알려줍니다.

위의 프로퍼티들을 추가해주시고

```swift
struct TagDetailsPage: Component {
    let items: [Item<Example>]
    let context: PublishingContext<Example>
    let selectedTag: Tag

    var body: Component {
        ComponentGroup {
            HeaderComponent(context: context)
            Div {
                H2(selectedTag.string)
                PostsLayout(items: items)
            }
            .class("site-tagDetails")
            FooterComponent()
        }
    }
}
```

기존의 `PostsLayout` 을 가져오는 방식으로 간단하게 처리하고

```swift
func makeTagDetailsHTML(for page: Publish.TagDetailsPage, context: PublishingContext<Example>) throws -> HTML? {
    HTML(
        .lang(context.site.language),
        .head(for: page, on: context.site),
        .body {
            TagDetailsPage(
                items: context.items(
                    taggedWith: page.tag,
                    sortedBy: \.date
                ),
                context: context,
                selectedTag: page.tag
            )
        }
    )
}
```

이렇게 `HTMLFactory`의 `makeTagDetailsHTML`에 넣어주시면 되는데,

```swift
items: context.items(
    taggedWith: page.tag,
    sortedBy: \.date
),
```

`items`를 가져오는 부분을 보면 context의 items를 가져오는데 `page.tag`가 포함되어 있는 `item` 만 가져오게 해준다라고 생각하시면 될것 같습니다.

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/30e5ace0-1f7e-408a-b779-687e48114af1"></img>

이런식으로 Tag를 눌렀을때 잘 조회가 되는것을 확인할 수 있습니다.
이렇게 해서 저희는 Publish로 웹사이트 하나를 뚝딱 만들어 봤습니다.

위에서 진행한 내용은 [예시코드](https://github.com/Jihoonahn/Blog-Document/tree/main/Publish/part2) 를 확인할 수 있습니다.

---

이번 글에서는 Publish에서 HTML을 작성하는 방법과, 직접 예제를 만들어보며 Publish를 이용해서 실질적인 웹사이트를 만들어 봤습니다.

다음글에서는 Publish로 만든 웹사이트를 배포하는 법에 대해서 작성할 예정입니다.
