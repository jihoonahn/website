---
title: Publish 사용하기 part 3
date: 2023-11-18 15:48
tags: Swift, Publish, Web, Theory
image: thumbnail/publish-part-3.svg
description: Swift publish 배포하기
---

## Publish 배포 준비하기

일단 배포 준비를 하기 위해서는 publish pipeline에서 수정할 부분이 있습니다.

```swift
// This will generate your website using the built-in Foundation theme:
try Example().publish(using: [
    .optional(.copyResources()),
    .addMarkdownFiles(),
    .generateHTML(withTheme: .publish),
    .generateRSSFeed(including: [.blog]),
    .generateSiteMap(),
    /// Deploy 관련
    .deploy(using: ///배포 방식 )
])
```

기존에 만든 pipeline에서 `deploy(using:)` 메서드를 추가해줍니다.

```swift
static func gitHub(
    _ repository: String,
    branch: String = "master",
    useSSH: Bool = true
) -> DeploymentMethod<Example>
```

- repository: 프로젝트 Repository
- branch: 배포할 Branch
- useSSH: SSH 키를 사용하는지 여부

```swift
.deploy(using: .git("git@ios.github.com:jihoonahn/ExamplePublish", branch: "gh-pages"))
```

저는 ssh키를 여러개를 사용하는 관계로 그냥 git으로 작성 하였습니다.

그리고 Website 부분에서

```swift
struct Example: Website {
    enum SectionID: String, WebsiteSectionID {
        case blog
        case about
        var name: String {
            switch self {
            case .blog: return "Blog"
            case .about: return "About"
            }
        }
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: /* URL 값 입력 */ )!
    var name = "Example"
    var description = "A description of Part"
    var language: Language { .english }
    var imagePath: Path? { nil }
}
```

URL 값을 입력해줍니다.

```swift
var url = URL(string: "https://jihoonahn.github.io/")!
```

Publish CLI를 보게 되면

```
Publish Command Line Interface
------------------------------
Interact with the Publish static site generator from
the command line, to create new websites, or to generate
and deploy existing ones.

Available commands:

- new: Set up a new website in the current folder.
- generate: Generate the website in the current folder.
- run: Generate and run a localhost server on default port 8000
       for the website in the current folder. Use the "-p"
       or "--port" option for customizing the default port.
- deploy: Generate and deploy the website in the current
       folder, according to its deployment method.
```

이런식으로 deploy 관련 커맨드가 있습니다.

```swift
$ publish generate
$ publish deploy
```

이렇게 명령어를 순차적으로 작성하게 되면,

<img width = 100% src="https://github.com/jihoonahn/blog/assets/68891494/20ec7f25-7aeb-441a-9ca7-240b39c7d1ca"></img>

이렇게 Deploy가 완료가 됬다는 내용과 함께

<img width=100% src="https://github.com/jihoonahn/blog/assets/68891494/696fd9de-df43-4b1d-8581-422e077698e0"></img>

- ❌ 포스트 올라간 후에 삭제될 Repository입니다.

이렇게 gh-pages에 잘 배포가 되는것을 확인 할 수 있습니다.

위에서 진행한 내용은 [예시코드](https://github.com/Jihoonahn/Blog-Document/tree/main/Publish/part3) 를 확인할 수 있습니다.

---

이번 글에서는 Publish에서 Deploy 하는 방법에 대해서 알아보면서,
총 publish를 사용하는 방법에 대해서 3개로 파트를 나눠서 제작을 하였습니다.

여러분도 한번 Publish로 자기만의 blog를 만들어 보는것은 어떤가요?
