---
title: Swift Concurrency
date: 2026-02-06 21:24
tags: Swift, Concurrency
image: thumbnail/swift-concurrency.svg
description: Swift Concurrency에 대해서 알아보겠습니다.
---

### Swift Concurrency란

Swift 5.5에서 나온 Swift Concurrency는 단순하게 `DispatchQueue`를 대체 하는것이 아닌 다양한 문제를 해결해 주는 강력한 도구이다.

- 비동기 로직이 늘어날 때 completion handler 지옥 발생
- 상태 기반 아키텍처 등에서 비동기 이벤트 스트림 처리의 복잡도 증가

### DispatchQueue, Swift Concurrency 비교

일단 먼저 DispatchQueue의 본질은

DispatchQueue는 아래 책임을 가진다.
- 작업(Block)을 queue에 넣는다
- 스레드 풀에 작업을 분배
- 직렬 / 병렬 실행을 보장한다

```swift
DispatchQueue.global().async { ... }
```

위 코드에서 GCD는 언젠가 실행되는것과, 현재 스레드 블로킹 하지 않음을 보장한다.
그리고 이 작업의 소유자, 취소 가능 여부, 다른 작업과의 관계, 데이터 레이스 방지, 상태 일관성 등은 보장하지 않는다.

즉 DispatchQueue는 실행기(executor)이지, 동시성 모델이 아니다.

#### DispatchQueue기반 동시성의 한계

```swift
var count = 0

DispatchQueue.global().async {
    count += 1
}
```

이 코드는 컴파일이 성공 하고, 런타임 겅공이 가능하며, 결과는 비결정적이며 데이터레이스는 전적으로 개발자의 책임이다.

```swift
let queue = DispatchQueue(label: "counter")

queue.async {
    count += 1
}
```

해결하기 위해서 위 코드 처럼 작성하면, 결국 설계 부담이 전부 개발자에게 오게 된다.

### Swift Concurrency의 핵심 철학

1. Structed Concurrency
2. Cooperative Thread Pool (Swift Runtime)
3. Date Race를 컴파일 타임에 차단하는 시도

```swift
async let a = fetchA()
async let b = fetchB()
let result = await a + b
```

이런 식으로 사용하게 되면 이러한 장점을 챙길 수 있다.

- `a`, `b`의 부모 스코프에 생명주기가 종속됨
- 부모 Task 가 cancel 되면 자식 Task 도 함께 cancel 됨
- Task Tree가 명확해져서 디버깅 및 추론이 쉬워짐


Swift Concurrency로 이렇게 작성하면

```swift
Task {
    await doWork()
}
```

이러한 단계를 거친다.

1. Task 객체 생성
2. 부모 Task 에 구조적으로 연결
3. 취소 전파 경로 확보
4. 실행은 Executor에 위임
5. Actor isolation 검사

즉 Swift Concurrency는 실행을 직접하는것이 아닌, 실행은 `Executor`가 하고 그 밑에 GCD 가 존재한다.

### Swift Concurrency 동작
#### Executor
- Swift Concurrency의 실행 단위
- Task를 실제 스레드에 매핑
- 대표적인 Executor
    - MainActor executor -> main thread
    - Global executor -> cooperative thread pool

#### 내부 구조
- Global executor은 libdispatch(GCD) 위에서 동작
- cooperative scheduling (thread 점유 최소화)

> Swift Concurrency → Executor → GCD → Kernel Thread

방식으로 구동되며, DispatchQueue가 대체 된다고 보다는 밑으로 내려간게 맞다.

### 예제
#### DispatchQueue
```swift
func loadUser(completion: @escaping (User) -> Void) {
    DispatchQueue.global().async {
        let user = fetchUser()
        DispatchQueue.main.async {
            completion(user)
        }
    }
}
```

#### Swift Concurrency
```swift
func loadUser() async throws -> User {
    try await fetchUser()
}
```

DispatchQueue랑 Swift Concurrency는 표현력부터 다르다.

현재 위 두개의 예시를 비교 하면, DispatchQueue는 흐름이 분산되고, 에러 전달도 복잡하고, 취소가 불가능하며 테스트의 어려움을 겪을수 있다.

하지만 Swift Concurrency를 사용한 곳에서는, 동기 코드 처럼 가독성이 올라갔고, 에러 전파가 자동으로 되며, Task cancel이 가능하고 테스트가 용이 하다는 장점이 있다.


### 구조적 동시성 vs 비구조적 동시성

DispatchQueue
- 작업간 관계 없음
- fire-and-forget
- 추적 불가

Swift Concurrency
- 부모-자식 Task 트리
- 취소 / 에러 전파
- 생명주기 명확

### 결론

DispatchQueue를 써야 할 때
- C / legacy API 래핑
- barrier, concurrent queue 제어
- low-level synchronization
- 성능 실험

Swift Concurrency를 써야 할 때
- 앱 레벨 비동기 로직
- 네트워크 / IO
- 상태 기반 아키텍처
- 테스트 가능한 코드
