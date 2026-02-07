---
title: SwiftUI 소개
date: 2022-10-20 17:02
tags: Tutorial, SwiftUI, Theory
image: thumbnail/what-is-swiftui.svg
description: 선언형 UI로 생산성을 높여주는 SwiftUI에 대한 설명입니다.
---

<iframe src="https://www.youtube.com/embed/psL_5RIBqnY?start=7603" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

**본 영상은 WWDC 19이며 SwiftUI 소개되는 부분에서 시작이됩니다.**

2019년 애플의 WWDC에서 처음 소개된 SwiftUI 는 모든 애플 운영체제용 앱을 개발하는데 있어서 완전히 새로운 방법을 제공합니다.

SwiftUI의 기본적인 목적은 앱 개발을 더 쉽고 폭발적인 생산성을 내면서 동시에 소프트웨어를 개발할 때 일반적으로 발생하는 버그들을 줄이는 것입니다. <br/>
또한 개발 과정에서도 앱의 라이브 프리뷰 기능을 이용하여 SwiftUI 프로젝트를 실시간으로 테스트할 수 있게 합니다. <br/>

<img width="100%" src="https://user-images.githubusercontent.com/68891494/229286766-44425ba2-bc64-4955-b106-99d99904313f.png"></img>
위 이미지는 SwiftUI Project를 생성했을 때의 모습입니다. <br/><br/>

## SwiftUI의 선언적 구문

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.white)
        }
        .padding()
        .background(.black)
    }
}
```

UIKit과 인터페이스 빌더를 User Interface Layout을 설계하고 필요한 동작을 구현하는 것과는 완전히 다른 방법인 선언적 구문(declairactive syntax)이 SwiftUI에 도입되었습니다. <br/>
이 과정에서 기본적으로 레이아웃에 포함될 컴포넌트들을 선언하고, 그것들이 포함될 레이아웃 메니지 종류 (VStack, HStack, Form, List 등)를 명시하고, 속성을 설정하기 위해 수정자(modifier)를 사용합니다. <br/>
이렇게 선언하고 난 후 레이아웃의 위치와 constraint그리고 렌더링 방법에 대한 모든 복잡한 세부 사항은 SwiftUI가 자동으로 처리합니다. <br/>
SwiftUI 선언은 계층적으로 구조화 되어 있습니다. 따라서 복잡한 뷰를 보다 쉽게 생성할 수 있습니다. <br/> <br/>

## SwiftUI는 데이터 주도적

SwiftUI 이전에는 앱 내에 있는 데이터의 현재 값을 검사하려면 그에 대한 코드를 앱에 포함 해야했습니다. <br/>
시간에 지남에 따라 데이터가 변한다면 사용자 인터페이스가 데이터의 최신 상태를 항상 반영하도록 하는 코드를 작성하거나, 데이터가 변경되었는지 주기적으로 검사하는 코드를 작성하는 것, 그리고 갱신 메뉴를 제공 해야했습니다. <br/>
이러한 데이터 소스를 앱의 여러 영역에서 사용할 경우 소스 코드의 복잡도가 증가합니다. <br/>

> **SwiftUI는 앱의 데이터 모델과 사용자 인터페이스 컴포넌트, 그리고 기능을 제공하는 로직을 binding하는 여러방법으로 복잡도를 해결하게 됩니다.** <br/>

데이터 주도로 구현하면 데이터 모델은 앱의 다른 부분에서 subscibe 할 수 데이터 변수는 publish 하게 됩니다. (publisher – subsciber) <br/>
이러한 방법을 통해 데이터가 변경되었다는 사실을 모든 구독자에게 자동으로 알릴 수 있습니다.<br/>
만약 사용자 인터페이스 컴포넌트와 데이터 모델 간에 바인딩이 된다면, **추가적인 코드를 작성하지 않아도 모든 데이터의 변경 사항을 SwiftUI가 사용자 인터페이스에 자동으로 반영할 것**입니다. <br/><br/>

## UIKit VS SwiftUI

<img width="100%" src = "https://res.cloudinary.com/practicaldev/image/fetch/s--Ry1DiaP7--/c_imagga_scale,f_auto,fl_progressive,h_900,q_auto,w_1600/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/85fmihrdl249k9cuid1i.png"></img>

**UIKit**

```swift
import UIKit

final class ViewController: UIViewController {

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Hello UIKit", for: .normal)
        button.addTarget(self, action: #selector(helloUIKitButtonAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc private func helloUIKitButtonAction() {
        printContent("Hello UIKit!")
    }
}
```

**SwiftUI**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Hello SwiftUI") {
                print("Hello SwiftUI!")
            }
        }
        .background(.black)
    }
}
```

같은 동작을 하는 뷰를 만들어 봤습니다. <br/>

차이점이 보이시나요? UIKit(명령형)과 SwiftUI(선언형)을 비교해볼 때 <br/>

UIKit에서는 Property를 선언 view에 추가하고, Layout에 제약사항을 준 후, action을 할 함수를 만들어서 button에 addTarget 해줍니다. <br/>

하지만 SwiftUI에서는 그래로 원하는 위치에 Button을 추가하고 action을 추가하면 끝납니다. <br/>

생산성 부분에서 어마어마하게 차이가 난다는 걸 볼 수 있습니다. <br/><br/>

## UIKit과 SwiftUI를 함께 사용하는 방법

사실 UIView와 SwiftUI를 함께 사용할 수 있는 방법은 다양하게 존재합니다. <br/>

SwiftUI는 빠르고 효율적인 앱 개발 환경을 제공할 뿐만 아니라 코드를 크게 변경하지 않아도 다양한 애플 플랫폼에서 동일한 앱을 사용할 수 있게 합니다.<br/>

하지만 지도 또는 웹 뷰를 통합해야 하는 특정 기능은 여전히 UIKit을 사용해야 하고, 매우 복잡한 UI 레이아웃을 설계하는 경우에 SwiftUI 레이아웃 컨테이너 뷰 사용이 만족스럽지 않을 수 있습니다. <br/>

이런 상황에서는 인터페이스 빌더를 사용을 하는 방식으로 해결할 수도 있습니다. <br/><br/>

## 지금 SwiftUI는 어떨까?

현재까지는 시기상조라는 말도 있고, 회사에서 도입 할 것이라는 말이 있습니다. <br/>
이 부분은 사람마다 의견이 다르기 때문에 정확한 대답은 어렵지만, 개인적으로 저는 자신이 처한 상황에서 직접 고려하여 결정하는 것이 좋다고 생각합니다. <br/>

SwiftUI 최소 버전은 iOS 기준 13.0이지만, 제대로 사용하려면 15.0 이상이여야 하기 때문에, 이러한 부분은 좀 많이 아쉽긴 합니다. <br/>

그리고 현재 SwiftUI는 버그도 있기도 하고, 아직 사용하기에는 불완전하다는 말에 동의는 합니다. <br/>
하지만 엄청난 생산성을 갖는다는것, 그리고 Apple이 추구하는 방향성의 UI Framework라는 것은 부정할 수 없기 때문에, iOS 개발자로 살면 언젠가는 사용해야하기 때문에 미리 공부해 보는 것도 좋다고 생각을 합니다.
