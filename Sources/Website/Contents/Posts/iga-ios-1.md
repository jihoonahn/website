---
title: 제 1회 IGA 발표 회고록
date: 2023-07-10 13:22
tags: Recollection, Announcement
image: thumbnail/iga-ios-1.svg
description: IGA 발표 회고
---

<iframe src="https://www.youtube.com/embed/ugNe2yFBRDM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

이번 제 1회 iOS IGA에서 CLI 구축 방법에 대해서 발표를 했고, 이에 대한 회고 입니다. <br/><br/>

## 발표 준비

발표 전 원래 주제로 **"생산성으로 위한 Script"**에 대해서 발표를 하려고 생각하고 있었습니다. <br/>

하지만 Swift로 작성하는 Script는 하나의 작업을 실행하기 위해서 Script에 많은 양의 코드가 들어가고, 중복되는 코드.. 등등 제작하는 것도 리소스가 많이 소비가 되는데, 하나의 작업을 위해서 제작이 되기 때문에 사람들이 사용할만한 이유가 부족하다고 생각이 되었습니다. <br/>

여러가지 방법을 찾아보다가 Swift Argument Parser라는 라이브러리를 보게 되었고, 오히려 지금 제가 추구하는 생산성은 CLI 쪽이 맞겠다 생각을 해서, 주제를 **"생산성을 위한 CLI 구축"**으로 바꾸게 되었습니다. <br/>

이번 발표에서는 좋은 예제를 만들고 싶어서, 고민을 많이 했습니다.

```
1. CLI의 장점을 잘 보여주기 위해서 전용 CLI 제작
2. ML이라는 주제를 더 잘 녹여 낼 수 있는 GPT CLI 제작
```

2개의 주제를 가지고 일주일 정도를 고민했습니다. <br/>
1번을 선택하면 발표주제를 더 깊게 설명할 수 있고, 2번을 선택하면 컨퍼런스 주제와 CLI에 대한 흥미를 더 줄 수 있지 않을까? 라고 생각을 했습니다. <br/>

결과적으로는 컨퍼런스 주제를 더 잘 녹여내자는 생각에 2번을 선택했습니다. <br/><br/>

## 발표 시작

제 발표는 3번째였습니다.

<img width=100% src = "https://github.com/Jihoonahn/Blog/assets/68891494/e697dfeb-06c2-4a35-9ccb-66fbf2a92c4c"></img>

처음 추영욱님이 먼저 나가셔서 오프닝을 시작했습니다. 오프닝때 부터 반응이 좋았었고, 오프닝이 끝난 후
저 이전 발표자 분이신 긱코드님이 나가셔서 발표를 진행하셨는데 너무 발표를 재밌게 잘하셔서 더 떨리더라고요 ㅎㅎ.. <br/>

어느정도 떨긴 했지만 최대한 많은 내용을 전달하고자 하는 생각으로 발표를 시작하게 되었습니다.

<img width=100% src="https://github.com/Jihoonahn/Blog/assets/68891494/a70212a0-c9cb-42f4-8a1e-6674acd71103"></img>
<img width=100% src="https://github.com/Jihoonahn/Blog/assets/68891494/4bba15b6-63cb-4d70-8f07-45e55f77a40e"></img>

발표는 다음 순서로 진행이 됬습니다.

```
1. CLI 제작기
2. CLI vs Script
3. CLI 제작 방법
4. 예시 프로젝트
5. 저는 CLI를 이런 곳에 사용합니다.
6. CLI가 사용되는 곳
```

1번, 2번에서는 목차에서 제가 CLI를 제작하게 된 계기를 위에 Script와 고민했던 것, 그리고 그 이후에 CLI를 제작하게 된 배경에 대해서 설명하고 <br/>
3번째에는 **Swift Argument Parser** 사용 방법에 대해서 이야기 하고, <br/>
4번째에는 위에서 이야기한 CLI에서 GPT를 사용하는 예시 프로젝트에 대해서, <br/>
그리고 5번째는 CLI를 어디서 이용했는지에 대한 이야기를 하였고,<br/>
마지막은 대부분 iOS 개발자들이 알 수 있는 메이저한 라이브러리/프레임워크에서 어디에 사용됬는지에 대해서 이야기 했습니다. <br/><br/>

## 느낀점

저번에 와글와글 iOS 발표를 하고, 이번에는 처음으로 오프라인 발표를 해봤지만.. 확실히 온라인 발표와 오프라인 발표는 뭐가 쉬웠다 이런게 아닌 두가지 느낌이 완전히 다르다고 느껴졌습니다. <br/>

와글와글때는 온라인에서 발표 전에는 진정이 많이 됬는데, 진행하는 도중에 떨리게 되었고, 이번에 진행한 IGA 오프라인 발표는 발표전에 오히려 많이 떨리고, 진행하면서 진정이 많이되는 느낌을 받았습니다. <br/>

발표를 2번 진행하면서 이번에도 몇번씩 실수를 하는것을 보며, 여전히 부족하다는 것을 깨닳게 되었고, 이번에는 CLI라는 주제가 Swift에서는 자주 발표하는 주제가 아닌 만큼, 걱정이 많이 됬었지만 오거나이저 분들과 스피커 분들도 다들 좋게 말해주셔서 다행이라고 생각이 되었습니다.
