---
title: SwiftUI에 MVVM이 필요할까요?
date: 2022-9-21 12:00
tags: Swift, Architecture, SwiftUI, Debate
image: thumbnail/swiftui-need-mvvm.svg
description: 요즘 이슈가 되고 있는 내용으로, 과연 SwiftUI에는 MVVM이 필요한지에 대한 저의 주관적인 생각을 담은 글입니다.
---

## SwiftUI MVVM issue?

<img width = 100% src = "https://github.com/Jihoonahn/Blog/assets/68891494/cb143b4f-90af-499b-9cd9-6fa2e6ede38c"></img>

[Stop using MVVM for SwiftUI (apple developer forms)](https://developer.apple.com/forums/thread/699003) <br/>
[Stop using MVVM with SwiftUI (medium post)](https://medium.com/@karamage/stop-using-mvvm-with-swiftui-2c46eb2cc8dc)

위 글을 보면 SwiftUI에서 MVVM 사용을 멈추자는 의견을 제시하고 있습니다.

“SwiftUI에서 MVVM 사용 중지”라는 강력한 주제로 저의 관심을 끌었습니다.

글은 꽤나 논리적인 글이라고 생각이 되었습니다. SwiftUI내에서 MVVM의 사용을 의심하지 않았던 저에게는 진짜 많은 생각을 하게 만들었었습니다.

<img width = 100% src = "https://github.com/Jihoonahn/Blog/assets/68891494/ad50e41a-aacd-4e00-a7ce-c747beeb731b"></img>

[Is MVVM an anti-pattern in SwiftUI?](https://www.reddit.com/r/swift/comments/m60pv7/is_mvvm_an_antipattern_in_swiftui/)

Reddit에서도 issue가 된 내용입니다.

<br/>

### 여기서부터는 저의 생각이 들어갔습니다.

SwiftUI는? 선언형 뷰 프로그래밍 방식입니다.

**선언형 UI에서는 ViewModel은 필요할까** 라는 주제의 여러 글들을 보고 따로 공부와 여러가지 생각을 했습니다.

옛날에는 “MVVM이 무조건 좋다” 라는 인식이 존재했습니다. 그런데 SwiftUI로 개발을 하면서 억지로 ViewModel을 만드는 상황이 발생하고 있습니다.

ViewModel은 비즈니스 로직을 분리하는 목적으로 사용할 수 있기 때문에 ViewModel이 완전히 나쁘다 라고 하기는 어려울것 같습니다.

하지만 저는 SwiftUI의 View는 이미 View + ViewModel라고 생각하기 때문에 저는 불필요하다고 생각합니다.

<br/>

### SwiftUI에서의 View는 이미 View+ViewModel 입니다.

```swift
import SwiftUI

struct Content: View {
    @State var model = Themes.listModel

    var body: some View {
        List(model.items, action: model.selectItem) { item in
            Image(item.image)
            VStack(alignment: .leading) {
                Text(item.title)
                Text(item.subtitle)
                    .color(.gray)
            }
        }
    }
}
```

medium 블로그 글의 예시를 가져왔습니다.

예시처럼 SwiftUI의 View는 원래부터 데이터 바인딩 기능을 포함하고 있기 때문에, 모델 값을 View에 직접 Reactive하게 반영 할 수 있습니다.

ViewModel은 원래 상태를 View에 Binding하여 Reactive에 반영하기 위한 목적으로 도입되었습니다.

하지만 위 예시처럼 선언적 UI에는 해당 기능이 포함되어 있으므로 ViewModel은 필요하지 않다고 생각합니다.

<br/>

### 우리가 왜 MVVM이 무조건 좋다고 생각했을까요?

이것은 기존 사용했던 UIKit을 보고 알 수 있었습니다.

기존 코드에서는 rx를 통해 데이터 바인딩을 해주는 코드를 사용했습니다. (RxSwift를 사용했을 때)
흔하게 알고 있는 ViewModel을 통해서 뷰와 데이터 바인딩을 해주는 MVVM 구조입니다.

ViewModel의 가장 중요한 역할은 데이터 바인딩입니다. 모델과 뷰 사이에 양방향 통신을 해주면서 바인딩을 시켜줍니다.

**하지만 SwiftUI에서는 View에서 다 해줄 수 있기 때문에 필요가 없다는 생각이 됩니다.**
<br/>

### SwiftUI에 MVVM을 사용하는 것은 복잡도를 올리게 됩니다.

SwiftUI에서 MVVM을 사용하게 되면, ViewModel이라는 레이어가 추가되기 때문에 복잡도가 증가합니다.

또한 Data Flow는 ViewModel이 View와 Model의 중간 레이어와 함께 배치되어서 양방향으로 동작하게 됩니다.

<img width="100%" alt="my-option" src="https://user-images.githubusercontent.com/73165292/196845240-6b0ed156-f79f-4d70-9b13-fcabe343725b.png">
</img>

[Apple Document](https://developer.apple.com/documentation/swiftui/model-data)

**선언형 UI를 사용하는 환경에서는 단방향 데이터 플로우 구조를 지향합니다.**

현재 많은 개발자들이 아키텍처 패턴으로 MVVM을 사용합니다.

많은 자료들이 SwiftUI + MVVM을 사용하는 방법에 대해서 설명을 하고 있기도 합니다.

<br/>

## 이미 Vue나 React, Flutter 모두 MVVM을 사용하고 있지 않습니다.

세가지의 모두 공통점으로 선언형 UI를 사용한다는 것을 알 수 있습니다.

그러면 MVVM 말고 SwiftUI에서 무엇을 사용해야 할까요?

### 그럼 뭘 사용하라는 건가

ViewModel을 사용하지 않는다면 비즈니스 로직과 UI 로직을 어떻게 어디서 분리해야 할까요?

[Realm](https://www.youtube.com/watch?v=mTv96vqTDhc&t=756s)에서는 MVI 접근 방식을 지향한다고 합니다.

3가지 방법을 생각해볼 수 있습니다.

1. Model에서 이를 구현한다. (MV)
2. MVI (Model-View-Intent)
3. Flux 개념의 Store로 분리한다.

첫번째 방법은 선언적 UI에 어울리는 단방향 플로우의 장점을 챙겨가지 못하기 때문에 적합하지 않고,

그렇기 때문에 MVI 와 Flux 및 Store/Provider 패턴이 적합하다고 생각합니다.

---

저는 이 논쟁에 대해 저의 생각을 답글에 달았습니다.

<img width="100%" alt="my-option" src="https://user-images.githubusercontent.com/73165292/196845524-2621e870-0fc8-4caf-b636-34aa2a452be9.png">
</img>
