---
title: Swift Layout 제작기
date: 2025-12-15 11:00
tags: Swift, Layout, SwiftUI DSL, Manual-Layout
image: thumbnail/swift-layout.svg
description: UIKit 기반 Manual Layout을 사용하는 SwiftUI DSL 라이브러리 제작기 입니다.
---

## Layout 제작기

iOS 를 공부하며, 2022년도 부터 고민한 내용입니다. 저는 Snapkit, PinLayout, FlexLayout.. 등등 여러가지 라이브러리를 사용하여 UI의 Layout을 작성해왔습니다. 그러다가 하이퍼 커넥트의 [HypeUI](https://github.com/hyperconnect/HypeUI) 라는 라이브러리를 보았습니다.

기존 UIKit에서 많이 사용되는 Snapkit과 PinLayout의 예시를 보면

- Snapkit

```swift
viewA.snp.makeConstraints { (make) -> Void in
    make.width.height.equalTo(50)
    make.center.equalTo(self.view)
}
```

- PinLayout

```swift
viewA.pin.top(10).bottom(10).left(10).right(10)
```

사실 두가지도 Auto Layout과 Manual Layout으로 동작 방식 부터 차이가 있지만 생산성 측면으로 일단 이야기 하겠습니다.

```swift
ZStack {
    HStack(alinement: .center, spacing: 4) {
        Image(Asset.icStar.image)
            .frame(width: 12, height: 12)
        Text()
            .foregroundColor(UIColor.black)
            .font(UIFont.systemFont(ofSize: 14, weight: .regular))
        Spacer()
    }
    VStack {
        Text()
            .foregroundColor(UIColor.black)
            .font(UIFont.systemFont(ofSize: 14, weight: .regular))
        Spacer()
    }
}
```

HypeUI는 SwiftUI의 스타일을 AutoLayout에 입히므로써 생산성을 극도로 높힙니다.

그러다 문뜩 그 생각이 들었습니다

왜 SwiftUI 의 생산성과, Manual Layout의 성능을 둘다 챙길수 있다면 두마리의 토끼를 다 잡을수 있지 않을까? 라고 머리에서 생각이 들었습니다.

### Auto Layout과 Manual Layout은 어째서 성능이 차이가 날까

**Auto Layout**은 기존에 Constraint Resolver 라는 계산 엔진을 사용합니다.
이 Constraint Resolver는 Auto Layout의 Constraint(제약사항을) 만족하도록 Frame을 계산하는 방식이고

```
1. Constraints 수집
2. 시스템 제약 추가
3. 우선순위 정렬
4. 선형 방정식 시스템 생성
5. Solver 실행
6. Frame 계산
7. layoutSubviews() 호출
```

이러한 흐름을 거쳐서 Auto Layout이 실행이 됩니다.

Auto Layout같은 경우는 Solver를 실행할때 많은 CPU 비용이 발생하게 됩니다.

**Manual Layout**

Manual Layout은 Constraints 수집, Priority 정렬등 AutoLayout에서 해주는 기본적인 계산 로직이 빠지고 오로지 개발자가 Frame으로 값을 계산해서 대입을 합니다.

사실상 복잡한 레이아웃의 계산 로직을 모두 제거 했기 때문에
CPU, 메모리, 속도 모두 잡은 오로지 최적화된 로직을 작성할수 있습니다.

### Layout 라이브러리 소개

본격적으로 제가 만든 Layout에 대한 동작방식부터 자세히 설명드리도록 하겠습니다.
저는 Manual Layout에서 SwiftUI의 생산성을 가지게 하기 위해서
[Layout](https://github.com/pelagornis/swift-layout.git) 이라는 라이브러리를 제작하였습니다.

Layout은 SwiftUI DSL하여 SwiftUI가 익숙한 사람이여도 사용할수 있게 하였고 DSL한 내용을 순차적으로 수학적으로 좌표 계산을 하기 때문에 Manual Layout의 성능도 챙겼습니다.

```swift
@LayoutBuilder
var body: some Layout {
    VStack {
        titleLabel.layout()
    }
}
```

이런식으로 Layout을 작성합니다.

```swift
layoutContainer.setBody { self.body }
```

`LayoutContainer` 라는 단일 parent를 사용해서 처리를 하고

Stack 기능은 총 3가지의 Stack을 제공하며 (VStack, HStack, ZStack)

```swift
VStack { ... }
HStack { ... }
ZStack { ... }
```

Stack의 로직은 children view들의 desired size 계산하고 spacing만큼 offset을 누적하며, 최종 positions 결정하여 각각 Frame을 작성하게 설계하였습니다.

기존 UIStackView와 비슷한 원리지만 constraint solver 없이 순차 계산이 진행을 합니다.

내부 Layout의 위치를 잡는 방법은

```swift
label.layout()
    .centerX()
    .position(y: 20)
```

이런식으로 Layout에서 자체 제공하는 함수로 진행이 됩니다. (PinLayout을 조금 참고하였습니다.)

또한 `Spacer` 기능을 제공합니다.

```swift
Spacer()
Spacer(minLength: 50)
```

이런 식으로 SwiftUI와 같은 방식으로 제공됩니다.
Layout 프로토콜을 채택하였고, 사실상 Stack 내부에서 남은 영역에 대한 계산을 하여, 공간을 채우는 방식으로 처리를 하였습니다.

그리고 여러가지 Layout Modifiers를 제공하여 더욱 SwiftUI와 같은 스타일로 개발자의 편의를 추가하였습니다.

`size`

```swift
// Fixed size
myView.layout()
    .size(width: 200, height: 100)

// Width only (height flexible)
myView.layout()
    .size(width: 200)

// Height only (width flexible)
myView.layout()
    .size(height: 50)
```

`padding`

```swift
// Uniform padding
VStack { ... }
    .padding(20)

// Edge-specific padding
VStack { ... }
    .padding(UIEdgeInsets(top: 20, left: 16, bottom: 40, right: 16))
```

`offset`

```swift
// Move view from its calculated position
myView.layout()
    .size(width: 100, height: 100)
    .offset(x: 10, y: -5)
```

`Background`

```swift
VStack { ... }
    .layout()
    .size(width: 300, height: 200)
    .background(.systemBlue)
```

`Corner Radius`

```swift
VStack { ... }
    .layout()
    .size(width: 300, height: 200)
    .background(.systemBlue)
    .cornerRadius(16)
```

등등 SwiftUI의 기능들을 가져와서 사용자가 편하게 설정할수 있도록 제작하였습니다.

추가적으로 `GeometryReader` 기능을 제공함으로써 Dynamic Layouts를 작성할수 있도록 하였습니다.

```swift
GeometryReader { proxy in
    // Use proxy.size for dynamic sizing
    VStack(alignment: .center, spacing: 8) {
        topBox.layout()
            .size(width: proxy.size.width * 0.8, height: 60)

        bottomBox.layout()
            .size(width: proxy.size.width * 0.6, height: 40)
    }
}
.layout()
.size(width: 360, height: 140)
```

`GeometryReader` 는 이렇게 동작합니다

```swift
layoutContainer.layoutSubviews()
```

root Layout에게 availableSize 전달을 합니다.

```swift
func measure(in size: CGSize) -> CGSize
```

그리고 `GeometryReader.measure()` 를 실행시켜 부모가 준 사이즈 그대로 반환합니다, 그리고 GeometryReader에서 자식의 사이즈를 직접 측정하지 않습니다.

```swift
let proxy = GeometryProxy(
    size: rect.size,
    frame: rect
)

let contentLayout = content(proxy)
contentLayout.layout(in: rect)
```

그 다음으로 `GeometryProxy` 의 `layout(in rect: CGRect)`에서 부모가 계산한 최종 rect를 받고, `GeometryProxy` 생성하고 클로저를 실행시켜 Layout을 생성하는 구조입니다.

### 직접 Layout을 구현해보며,

사실상 기존 ManualLayout 과 SwiftUI DSL 코드 여러가지 코드를 레퍼런스를 삼고 정말 시행착오가 많았습니다.

라이브러리로 프로토타입을 짜고 Example 앱에서 직접 하나하나 정확한 위치에 찍히나 수치와, 제대로 UI가 나오는지 보느라 정말 많은 시간이 사용되었습니다.

Stack을 처음에 Layout으로 구성했다가, 조금만 복잡한 로직이 들어가는 순간 무너지고, Child Layout에 대한 처리를 하면 제각각 놀아버리는 상황이 생겨서 생각을 바꿔서 UIView 안에 childView로 처리 하는 방식까지 가면서도, 정말 기존 아무런 토대도 없을때 Layout Library를 작성하는 개발자 분들께 존경심이 느껴졌습니다.

그리고 Spacer 기능을 추가하는 순간 여러가지 문제가 생겨버렸습니다.
`ScrollView`안에 `Spacer()`가 있는 경우 처리와 기존엔 Stack들 안에서 Spacer가 어떻게 빈 공간을 계산하고 채워나갈지 작성을 했는데, ScrollView 기능 까지 추가하니, 무한대로 늘어나 버리기도 하고, SwiftUI 에서는 ScrollView 안에 Spacer가 있으면 `.zero`로 바꿔주던걸 생각해서 처리를 따로 해야되는 지경에 이르고.. 갈엎갈엎을 정말 이제껏 라이브러리를 많이 만들어오며 가장 많이 한 것 같습니다.

### 그래도 인간승리

Example앱들도

<img width = 50% src="https://github.com/user-attachments/assets/bb9c9a83-63c1-4f3b-8a75-d5dee22291b5" />
<img width = 50% src="https://github.com/user-attachments/assets/e7a47f4a-ac94-4c26-b293-51dac9c9cccb" />
<img width = 50% src="https://github.com/user-attachments/assets/d4fb1ba4-b8c4-4199-b1ef-defe8d7e747d" />
<img width = 50% src="https://github.com/user-attachments/assets/2f7aa888-564f-44aa-a7dc-55d0a3fe5c65" />
<img width = 50% src="https://github.com/user-attachments/assets/d9e50dc9-48cb-4055-868c-4b0b3d6355f6" />

이렇게 잘 작동을 하니 개발하면서 정말 만족도가 높았습니다. 개발을 하며 Layout System에 대해 더욱 더 깊은 지식과, 워낙 난이도가 높은 작업이다보니 저의 개발 능력도 한단계 더 올라간것 같습니다, 추후 이것으로 앱 하나를 만들어볼 생각하니 벌써부터 침이.. 쓰읍

지금까지 제가 만든 Layout 라이브러리에 대한 설명차 소개를 해봤습니다.

### 👏 기여자를 기다리고 있습니다!

그리고 저의 사심. Contributor를 기다리고 있습니다!
현재는 SwiftUI와 비교하면 아직은 부족한 라이브러리기 때문에 많은 관심을 받고 많은 기여를 받아서 좋은 라이브러리로 발전하는것을 목표로 하고 있습니다

많은 관심 부탁드립니다

[swift-layout에 pr 날리기](https://github.com/pelagornis/swift-layout/pulls) 👈
