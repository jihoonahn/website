---
title: TuistUI
date: 2025-04-08 23:29
tags: Swift, Tuist, Plugin, Tuistui
image: thumbnail/tuistui.svg
description: Tuist를 SwiftUI 처럼 사용할 수 있는 DSL Plugin인 제가 만든 TuistUI를 소개합니다.
---

# TuistUI

잠시 군대 복무 때문에 블로그 작성과 활동에 제약(개발 환경 등등)이 생겨서 글을 작성하지 못한 상태였으나, 이제 곧 전역을 준비하며.. 다시 시작 해볼려고 합니다. 이번에는 제가 애정있는 프로젝트이자, 군대에서도 유지보수를 했었고, 외출/외박때도 열심히 기능을 생각하던 애착 프로젝트를 소개할려고 합니다.

> TuistUI는 Tuist를 SwiftUI처럼 가독성 있게 사용하기 위해 만든 Tuist DSL Plugin입니다.

TuistUI를 사용하기 위해서는 `Config.swift` 에 아래 코드를 추가하면 됩니다.

```swift
import ProjectDescription

let config = Config(
    plugins: [
        .git(url: "https://github.com/jihoonme/tuistui", tag: "vTAG")
    ]
)
```

## 플러그인 개발 동기

아이디어는 SwiftUI를 보면서 하게 되었습니다.

기존의 Tuist 같은 경우는 `Project` 생성과 `Workspace` 생성 부분이 마치 `Package.swift` 와 비슷하다고 생각이 들었습니다. 하지만 그 스타일에서 벗어나 SwiftUI처럼 한눈에 직관적으로 보이는 느낌으로 만들고 싶었습니다.

```swift
struct BaseView: View {
	var body: some View {
		VStack {
			Text("Hello World")
		}
	}
}
```

관심있게 보던 프로젝트인 [`Tokamak`](https://github.com/TokamakUI/Tokamak) 프로젝트와 [`web`](https://github.com/swifweb/web) 그리고 [`Plot`](https://github.com/JohnSundell/Plot) 프로젝트를 참고해서 TuistUI의 전체적인 틀을 잡게 되었습니다.

# 어떤 기능을 가지고 있는가

## Module 기능

`TuistUI`는 Project든 Workspace든 `Module` 이라는 프로토콜을 상속 받는것으로 시작이 됩니다.

```swift
struct BaseFeature: Module {}
```

Module을 상속을 받게 되면 SwiftUI 처럼

```swift
struct BaseFeature: Module {
  var body: some Module {}
}
```

body 값을 받을수 있는 프로퍼티가 생성이 됩니다.

만약에 Project를 고르고 싶다면

```swift
struct BaseFeature: Module {
	var body: some Module {
	  Project {}
	}
}
```

`Module`을 상속 받고 있는 `Project` 를 body 프로퍼티 안에 적어두면 됩니다.

그 후에 설정할 값들을 넣어주고

```swift
struct BaseFeature: Module {
    var body: some Module {
        Project {
            /// Target Code
        }
        .organizationName("")
        .package {
            /// Package Code
        }
    }
}
```

기존 Tuist 의 `name:` 부분은

```swift
let project = Project(
	name: "BaseFeature"
	...
)
```

구조체명을 자동적으로 가져오게 설정해뒀습니다.

`Project.swift` 파일에 아래 코드만 추가해주시면 됩니다.

```swift
let project = BaseFeature().module()
```

그리고 `Workspace` 같은 경우도 똑같이 생성이 됩니다.

Module 안에 Workspace에 필요한 값을 넣어주고

```swift
struct TuistApp: Module {
    var body: some Module {
        Workspace {
            Path.relativeToRoot("Projects/App")
        }
        .scheme {
            /// Scheme Code
        }
    }
}
```

`Workspace.swift` 파일 안에 위 코드만 추가하면 됩니다.

```swift
let workspace = TuistApp().module()
```

## Constant 값 관리

SwiftUI에서 `@EnvironmentObject` 와 `ObservableObject` 부분을 보고 공통된 Constant를 관리해줄수 있는 공간이 있다면 괜찮을거 같다는 생각을 가지게 되어서 만들게 되었습니다.

`ModuleObject`라는 프로토콜을 만들었고, 그곳 내부에서 Module 에서 사용되는 값들을 전체적으로 관리할수 있도록 구성했습니다.

```swift
struct AppEnvironment: ModuleObject {
    static let organizationName: String = "jihoonme"
    static let destinations: Destinations = .iOS
    static let deploymentTargets: DeploymentTargets = .iOS("15.0")
}
```

그리고 SwiftUI에서 `@EnvironmentObject` 가 존재하듯 `@Constant` 라는 propertywrapper를 Module내부에 추가해주시면 값들을 편리하게 사용할 수 있습니다.

```swift
struct BaseProject: Module {
    @Constant var env = AppEnvironment()

    var body: Module {
        Project {
            // Target
        }
        .organizationName(env.organizationName)
    }
}
```

## Configuration 기능

마지막으로 고민했던 부분은 Configuration관련 내용입니다. TuistUI를 확장하며, Configuration 기능에 좀 `TCA` 처럼 정규화된 코드를 작성하면 이 플러그인만 가져오면 관리를 편하게 할 수 있겠다고 생각하게 되었습니다.

그래서 `TCA` 의 `Reducer` 스타일을 살짝 빌려서

```swift
struct AppConfiguration: XCConfig {

    enum XCConfigTarget: String, XCConfigTargetType {
        case baseProject

        var path: Path {
            switch self {
            case .baseProject:
                return .relativeToRoot("XCConfig/baseProject")
            }
        }
    }

    var body: some XCConfigOf<Self> {
        Configure ({
            switch $0 {
            case .baseProject:
                return [
                    // Write Configuration Method
                ]
            }
        })
    }
}
```

`XCConfigTarget`을 지정하고 body 프로퍼티에서 Configuration Method를 관리해줄수 있도록 만들었습니다.

```swift
var body: some XCConfigOf<Self> {
    Configure ({
        switch $0 {
        case .A:
            return [
                .debug(into: $0, name: .dev)
                .release(into: $0, name: .prod)
            ]
        }
    })
}
```

이렇게 추가하고

```swift
struct BaseProject: Module {
    let config = AppConfiguration()

    var body: Module {
        Project {
            // Target
        }
        .settings(
            .settings(
                configurations: config.configure(into: .baseProject)
            )
        )
    }
}
```

settings 부분에서 configurations를 추가하면 보기 좋게 관리 할수 있도록 만들었습니다.

## 고민했던 부분

플러그인 개발을 진행하면서 이런 부분은 고민을 많이 했습니다.

- Templates 제공 때 어떻게 제공하는게 좋을지
- Moduler Architecture 부분까지 제공을 할지

위 두가지 고민이 저에게 가장 큰 고민이였습니다.

### Templates 제공 때 어떻게 제공하는게 좋을지

이 부분은 생각보다 고민시간이 많이 걸렸습니다. 기존 대부분의 Templates 처럼 그냥 `Project.swift` 랑 `Workspace.swift` 파일을 생성하게 만들려고 했지만, `ProjectDescriptionHelpers` 부분에 초점을 두게 되었습니다.

실질적으로 `Module` 부분은 Project를 Description 해주는 부분이라고 생각이 들었습니다.

```swift
struct BaseFeature: Module {
    var body: some Module {
        Project {
            /// Target Code
        }
        .organizationName("")
        .package {
            /// Package Code
        }
    }
}
```

사실상 Project는 `Project.swift` 라는 부분에서 하는 역할은

```swift
let project = BaseFeature().module()
```

생성에 관련된 코드는 이 부분이 하고 있기 때문에 프로젝트 생성을 했을때 `Project.swift` 보다는 `ProjectDescriptionHelper` 에 생성되는게 더 의미가 맞겠다라고 생각을 해서

Project Template를 생성해주면

```
.
├── Projects
│   └── App
│     └── Project.swift //<- Project.swift file Generate
├── Tuist
│   ├── ProjectDescriptionHelpers
│     └── Projects
│       └── DemoProject.swift //<- DemoProject.swift file Generate
│   ├── Dependencies.swift
│   ├── Config.swift
│   └── Package.swift
└── [README.md](http://readme.md/)
```

이렇게 생성이 되며

Workspace도 마찬가지로 Template를 생성해주면

```
.
├── Projects
│   └── App
│     └── Workspace.swift //<- Workspace.swift file Generate
├── Tuist
│   ├── ProjectDescriptionHelpers
│     └── Workspace
│       └── DemoApp.swift //<- DemoApp.swift file Generate
│   ├── Dependencies.swift
│   ├── Config.swift
│   └── Package.swift
└── README.md
```

이렇게 생성되게 만들어뒀습니다.

### Moduler Architecture 부분까지 제공을 할지

이부분은 기존에 또다른 플러그인인 [microfeature](https://github.com/jihoonahn/microfeature) 플러그인을 만들어보며 또 다른 플러그인으로 제공을 하게되면

microfeature plugin 코드중

```swift
struct ExampleModule: Module {
    var body: some Module {
        Project {
            Microfeature {
                Example(name: typeName)
                Interface(name: typeName)
                Sources(name: typeName)
                Testing(name: typeName)
                UnitTests(name: typeName)
                UITests(name: typeName)
            }
        }
    }
}
```

이렇게 Microfeature라는 Method로 감싸야되는 상황이 나오게 됬습니다.

```swift
public func Microfeature(@TargetBuilder content: () -> [Target]) -> [Target] {
    return content()
}
```

Microfeature 플러그인을 제작할때 TuistUI를 가져올수 없기 때문에 발생하는 사소한 부분이였기 때문에 플러그인으로 가져오는건 비 효율적이라고 생각이 들었고,

**TuistUI 내부에서 Moduler Architecture를 넣어둔다면?**

이부분은 또 다른 모듈을 관리하는 Architecture가 나올수 있다는 것을 가정하에 제외하게 되었습니다. (TuistUI가 Modular Architecture 하나로만 제한되는 상황을 방지하기 위함입니다.)

## 향후 개발 계획

현재는 넘어가서 전역 후 [DesignTuist](https://github.com/jihoonme/designtuist) 에서 TuistUI 플러그인을 사용하며, 필요한 부분과 개선할 부분을 찾아볼 생각이고

추가적으로 이런 부분 추가하면 좋겠다 생각되시는 부분은 [issue](https://github.com/jihoonme/tuistui/issues)로 남겨주시면 열심히 추가해보겠습니다!

[https://github.com/jihoonme/tuistui](https://github.com/jihoonme/tuistui)
