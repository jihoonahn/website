---
title: Publish 소개
date: 2023-08-22 16:51
tags: Swift, Publish, Web, Theory
image: thumbnail/publish-introduce.svg
description: Swift로 Static Site 만들기
---

## What is Publish

[Publish](https://github.com/JohnSundell/Publish.git)는 John Sundell님이 만든 정적사이트 생성기 입니다. <br/>
Markdown Parser인 Ink와 Swift에서 HTML, XML, RSS를 작성하기 위한 DSL인 Plot을 사용합니다. <br/>

Swift Package로 제공되기 때문에 `Package.swift` 에 Dependency로 추가하여 사용할 수 있습니다. <br/>

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", from: "0.9.0")
    ]
    ...
)
```

Publish에서 제공하는 CLI를 설치할 때 HomeBrew를 지원하며, 깃허브로 따로 설치할 수도 있습니다.

```
brew install publish
```

또는 깃허브에서

```shell
$ git clone https://github.com/JohnSundell/Publish.git
$ cd Publish
$ make
```

이렇게 설치하면 됩니다. <br/>

이제 시작할 때

```
$ mkdir Example
$ cd Example
$ publish new
```

명령어를 이용하면?

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/1c06f812-0dbc-4fc0-a329-28d807544a55"></img>

이렇게 파일이 생성이 됩니다.

```
$ publish run
```

위 명령어를 통해서 웹사이트를 실행시키면

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/0a9e2214-6c6f-4efc-9b16-6d56acd07051"></img>

publish에서 제공하는 기본 화면이 보이게 됩니다.

실행 시키고 나면, Output 폴더가 생기게 됩니다.

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/d4239408-0148-427a-99f7-17cbfd2d87d2"></img>

그리고 내용 같은 경우는 `Content` 폴더 안에서 입력이 가능합니다. <br/>
일단 방금 만든 예시로, 첫번째 post 파일을 수정해 보겠습니다.

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/5325cf79-11d9-4983-a14e-74be5fd4e042"></img>

이렇게 수정하고 다시 빌드 해보면?

<img width="100%" src="https://github.com/jihoonahn/blog/assets/68891494/707f8bc8-cc8b-4202-8444-3baef852be14"></img>

이렇게 내용이 잘 적용이 된것을 확인 할 수 있습니다.

그리고 글 추가 같은 경우는 markdown File 하나만 만들면 됩니다. (간단하죠?)

<img width="80%" src="https://github.com/Jihoonahn/Blog/assets/68891494/41491c29-dd6f-4755-a781-2da942e1dac0"></img>

이렇게 글을 추가해 주면 됩니다.

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/eb4533d5-8c5c-48ae-abad-26daba835ec9"></img>

그러면 추가된 글 까지 보이게 되죠,

글을 적는 방법을 알아볼까요?

```markdown
---
date: 2023-08-25 17:09
description: Welcome to publish.
tags: publish, web, static site
---
```

markdown file 위에 정보를 입력해줍니다. <br/>
date는 언제 이 글을 작성했는지를 보여주고, description은 글에 대한 짧은 설명을 적습니다. <br/>

그리고 publish 에서는 tag기능을 제공합니다. 저기에 tag를 적어두면?

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/7e5b11ae-798d-45ce-977e-d939f7c1cbde"></img>

이렇게 `https://localhost:8000/tags`에 tag들이 추가 되고, tag를 누르면?

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/9d4f0089-04bb-44b9-8052-5449e69d9bb4"></img>

tag를 가지고 있는 글들을 조회할 수도 있습니다.

---

이번 글에서는 간단하게 publish에 대해서 소개하는 글을 적어봤습니다. <br/>
와글와글때 발표했던 내용이랑 중복되는 부분이 많았지만.. 다음 글에서는 publish 커스텀하는 방법, publish로 작성한 글 deploy 하기 등등 publish는 시리즈로 진행할 예정입니다.
