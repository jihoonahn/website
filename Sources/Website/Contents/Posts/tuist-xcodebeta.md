---
title: Xcode-Beta에서 Tuist 사용기
date: 2023-6-10 00:03
tags: Swift, Tuist, Beta
image: thumbnail/tuist-xcodebeta.svg
description: Xcode Beta에서 tuist edit 명령어에서 에러나는 부분을 해결하는 방법에 대한 포스트입니다.
---

## Beta를 사용했을때

최근에 WWDC23이 공개되었습니다. macOS에서 발표된 내용을 보고 macOS 14와 Xcode 15의 변화에 대해서 보기 위해서, 업데이트를 했습니다.

<img width="10%" src="https://github.com/jihoonahn/Blog/assets/68891494/9042ff22-337c-459b-b01b-4ab7718c4bcd"></img>

그렇게 봉인된.. Xcode..

macOS 14에서는 기존 Xcode 14.3.1(글 작성 기준)를 사용하지 못하게 됩니다. <br/>
그래서 Xcode 15를 설치해야합니다.

[Xcode 설치 링크](https://xcodereleases.com/)

## 어떤 문제가 있었나..

그렇게, Xcode 15를 설치하고 Tuist를 실행 했을 때, 이런 문제가 있더군요.
Tuist에서 `tuist edit` 명령어를 실행했을 때,

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/c22e5b50-273a-45ab-a96e-484d715b014a"></img>

이런 식으로 실행이 안되는 문제가 있었습니다. <br/>
이유는.. 위에서 빌드업 했지만, 문제는 [Tuist Command Service](https://github.com/tuist/tuist/blob/main/Sources/TuistKit/Services/EditService.swift) 부분에 있었습니다. <br/>

## 문제는 어디서?

```swift
try opener.open(path: workspacePath, application: selectedXcode.path, wait: true)
```

[tuist > Sources > TuistKit > Services > EditService.swift](https://github.com/tuist/tuist/blob/main/Sources/TuistKit/Services/EditService.swift)
의 78번째 줄

위 코드 부분에서 에러가 발생합니다. <br/>

Xcode 앱을 실행시키는 코드이고, 현재 Xcode는 위 그림처럼 봉인(?)당했기 때문에 Xcode앱을 열 수 없는 것입니다. <br/>

나머지 명령어에서는 문제가 없었지만, `tuist edit` 명령어에서만 문제가 생기더라고요. <br/>
이 문제에 대한 해결 방법은 없을까요? <br/>

## 해결 방법

### 1. Tuist 명령어만으로 해결하는 방법

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/cd7a8e9c-59c0-435b-9ff2-bb124bb8d9f8"></img>

`tuist edit -h`를 실행시켜 명령어를 찾아봅시다.

Tuist 공식 깃허브 코드에서는 permanent가 true면, Xcode앱을 실행시키지 않습니다.

```swift
let workspacePath = try projectEditor.edit(
    at: path,
    in: path,
    onlyCurrentDirectory: onlyCurrentDirectory,
    plugins: plugins
)
logger.notice("Xcode project generated at \(workspacePath.pathString)", metadata: .success)
```

그렇기 떄문에, `tuist edit --permanent` 명령어를 실행하면?

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/f71302cb-91ad-4e0c-a665-52dde3574409"></img>

에러가 발생하여 동작이 실패하지 않고, 아래 처럼 프로젝트와 워크스페이스 파일이 생성됩니다.

<img width="80%" src="https://github.com/Jihoonahn/Blog/assets/68891494/21ac8d5b-9353-4d04-846f-edaa4103fc0d"></img>

이런식으로 진행이 됬다면, Manifests.xcworkspace 파일을 눌러서, tuist 프로젝트를 수정할 수 있습니다.

### 2. xcode-select의 path를 변경하는 방법

<img width="50%" src="https://github.com/Jihoonahn/Blog/assets/68891494/7c9fb32e-6ea6-4154-99c3-fc4c470ad8f2"></img>

이 방법은 [baekteun](https://github.com/baekteun) 이라는 후배가 영감을 준 방법입니다.

터미널에서

```bash
sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer
```

이렇게 xcode-select에서 path를 변경해 줍니다.

그 이후 다시 `tuist edit` 명령어를 실행하면 됩니다.

<img width="100%" src="https://github.com/Jihoonahn/Blog/assets/68891494/ef3d3550-e18a-4d1b-8d76-2e8017574897"></img>

그렇게 되면 정상적으로 `tuist edit` 명령어가 작동합니다. <br/><br/>

## 후기

처음에 `tuist edit` 명령어가 작동하지 않아서 tuist의 명령어 코드를 보다가 첫번째 방법은 발견하게 되었고, 두번째 방법은 위에서 말했듯 후배에게 영감을 받아서 얻은 방법입니다.

Tuist에서 `Sources/TuistSupport/Xcode/XcodeController.swift` 부분을 보게 되면, `xcode-select -p` 를 통해서 Xcode의 developer 파일 경로를 받아오는 방식입니다.

```swift
/// Returns the selected Xcode. It uses xcode-select to determine
/// the Xcode that is selected in the environment.
///
/// - Returns: Selected Xcode.
/// - Throws: An error if it can't be obtained.
public func selected() throws -> Xcode? {
    // Return cached value if available
    if let cached = selectedXcode {
        return cached
    }

    // e.g. /Applications/Xcode.app/Contents/Developer
    guard let path = try? System.shared.capture(["xcode-select", "-p"]).spm_chomp() else {
        return nil
    }

    let xcode = try Xcode.read(path: try AbsolutePath(validating: path).parentDirectory.parentDirectory)
    selectedXcode = xcode
    return xcode
}
```

근데 처음에 시도할때는 `xcode-select` 명령어의 option에서 path를 따로 바꿀 수 있다는 사실을 망각하고 있었기 때문에, 다양한 방식을 찾은 거 같습니다.

어쨋든 Xcode-beta 또는 다른 버전의 Xcode 앱을 설치하고 `tuist edit` 명령어가 작동하지 않아서 당황하신 분들을 위해서 이 글을 적었습니다.

이 방식 외 더 좋은 방식에 대해서 알고 계신 분이 있다면, blog 댓글에 알려주세요.
