---
title: Scade 소개
date: 2023-03-17 21:24
tags: Swift, Cross Platform, Scade
image: thumbnail/scade-introduce.svg
description: Swift로 크로스플랫폼 만드는 방법을 아시나요?
---

## What is Scade?

Swift로 iOS 와 Android 개발을 동시에 할 수 있는 크로스 플랫폼입니다.

<img width = 100% src = "https://user-images.githubusercontent.com/68891494/225908911-ad6d8638-99a4-496e-ad4e-ccc62238fe81.png"></img>

[scade.io](https://www.scade.io)

전용 툴을 제공하며, 위 [링크](https://www.scade.io/download/)에서 다운 받을 수 있다. <br/>
Scade의 [공식문서](https://docs.scade.io/docs) 입니다.

---

### 어떻게 동작되는 걸까?

Swift코드를 네이티브 iOS와 Android를 바이너리로 컴파일하여, 앱을 빌드합니다. <br/>
현재 기준 Scade는 Swift 5.4를 지원합니다.
<img width = 100% src = "https://files.readme.io/448093c-scadecompiler.png"></img>

위 링크를 통해 전용 툴을 다운로드 받았다면
<img width=20% src = "https://user-images.githubusercontent.com/68891494/225911086-829ed397-231c-42f8-9286-30a14cea8887.png"></img>

이러한 어플리케이션을 확인할 수 있을겁니다.

그리고 Xcode와 AndroidStudio 설치까지 마치셨다면, [공식문서](https://docs.scade.io/docs/getting-started)를 보고 세팅해주시면 됩니다.

**중요**
<img width=100% src = "https://files.readme.io/353f9ab-Screenshot_2022-10-20_at_09.51.18.jpeg"></img>

이 부분의 세팅할 때 주의하시는 것이 좋습니다.

### 프로젝트 생성하기

IDE 내부에서 FILE| Name | New Project 로 프로젝트를 생성해줍니다.

<img width=100% alt="스크린샷 2023-03-18 오후 3 38 06" src="https://user-images.githubusercontent.com/68891494/226089798-20eb3b08-1c00-4aef-9c32-88c18c04909e.png"></img>
<img width=100% alt="스크린샷 2023-03-18 오후 3 38 20" src="https://user-images.githubusercontent.com/68891494/226089897-4f4940d2-fc90-4e21-9da5-11f00456b2a4.png"></img>

Scade IDE에서 프로젝트를 생성해주면 됩니다.

<img width=100% src = "https://user-images.githubusercontent.com/68891494/226188230-d29f816d-d73a-42b0-803d-ec8498550584.png"></img>

Scade같은 경우 3가지 종류의 로 빌드가 가능합니다. <br/>
자체 시뮬레이터인 Scade Simulator, iOS의 Simulator, Android Emulator

뷰 같은 경우 .page 파일에서 스토리보드와 비슷하게 되어 있는것을 확인 할 수 있고,

<img width = 100% src = "https://user-images.githubusercontent.com/68891494/226189250-92402bc0-7f11-428a-bbea-af726f0136b3.png"></img>

우측 + 버튼을 눌러서 Component를 가져올 수 있습니다.

<img width = 100% src = "https://user-images.githubusercontent.com/68891494/226189421-2d4ff86a-4841-4091-9b52-11c74ecb27d1.png"></img>

원하는 컴포넌트를 Drag & Drop 해주면 됩니다. (Storyboard와 같은 느낌이죠?)

<img width=100% src = "https://user-images.githubusercontent.com/68891494/226189572-c1c21fb6-0568-4466-9aed-8877b4c1f87a.png"></img>

Scade IDE 우측에 있는 옵션들을 수정하여, Component를 설정 할 수도 있습니다.

### 실행

한번 Android와 iOS에서 잘 돌아가는지 확인해 보겠습니다.

<img width=100% src = "https://github.com/jihoonahn/blog/assets/68891494/eddc178e-3b54-431d-8931-6b73c77fe6f6"></img>

좌 iOS Simulator, 우 Android Emulator

같은 UI로 잘 돌아가는 것을 확인 할 수 있습니다.

### Scade를 사용해보고 느낀점

현재 꾸준히 개발되고 있지만 현재는 Beta 버전이고, 현재 공개된 [Scade Platform Github](https://github.com/scade-platform)는 이곳입니다.
아쉽게도 Scade SDK는 오픈소스는 아니기 때문에 뭔가 아쉽다 라는 느낌을 받긴 했지만, Swift로 iOS, Android CrossPlatform 개발이 된다는 점에서 신기한 느낌을 받고, IDE에서 Storyboard와 같은 기능을 지원하는것도 신기했습니다.

아직 부족한 부분은 분명 있지만 현재 베타버전임을 감안하고, 몇년에 걸쳐서 개발이 되는것을 보아, <br/>
추후 정식 출시날도 기다려집니다.

제가 개인적으로 느낀 점은, 그저 신기하다에 그치지 않고 Scade는 생각보다 놀라운 도구 였습니다. <br/>

저의 주 언어인 Swift를 가지고 Android 와 iOS를 동시 개발 가능하게 해주기 때문에, 저에게는 큰 흥미를 주었던 것 같습니다.

현재 Scade의 미래가 어떻게 될지 모르지만 Scade는 Beta에서만 끝나지 않고, 늦어도 좋으니 정식 출시까지 했으면 좋겠다는 생각이 들었습니다. (추후 Apple에서 비슷한 걸 제공해도 좋고요 ㅎㅎ)

---

<br/>

이번에는 Scade에 대해서 소개하는 글이기 때문에, 간단하게 소개했기 때문에 여기에서 글을 끝내고 <br/>
나중에 Scade를 더 깊게 사용해보며, 글을 적도록 하겠습니다.
