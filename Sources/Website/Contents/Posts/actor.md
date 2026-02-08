---
title: Actor 란
date: 2026-02-07 21:30
tags: Swift, Concurrency, Actor
image: thumbnail/actor.svg
description: Actor에 대해서 알아보겠습니다.
---

### Actor 란
`Actor`는 Swift Concurrency에서 Data Race를 컴파일 타임에 방지하기 위해 도입된 reference 타입입니다.

Actor가 나오기 전엔, class는 여러 스레드에서 동시에 접근할 수 있기 때문에, 개발자가 직접 `DispatchQueue`, `NSLock`, `Semaphore` 등을 통해서 동기화를 보장해야했지만, 그로 인해 유지보수 비용이 매우 높아졌다.

하지만 Actor는 이를 언어 차원에서 해결해준다.


### Actor의 핵심 보장
- 한 시점에 단 하나의 Task만 actor의 mutable state에 접근 가능
- 동기화 코드를 직접 작성하지 않아도 됨
- 잘못된 동시 접근은 컴파일 에러로 차단

즉 Actor는 Thread-safe한 class를 기본값으로 제공한다고 하면 이해하기 쉽다.

### Actor의 기본 구조
```swift
actor Counter {
    var value: Int = 0


    func increment() {
        value += 1
    }


    func getValue() -> Int {
        value
    }
}
```

사용법

```
let counter = Counter()


Task {
    await counter.increment()
    let value = await counter.getValue()
    print(value)
}
```

`actor` 내부의 `var`은 자동으로 보호되며 외부에서 접근시 반드시 `await`가 필요하고, 내부에서는 `await` 없이 자기 자신의 state 접근 가능하다.


### Actor Isolation
Actor에서는 Isolation이 존재한다.
- actor의 모든 mutable state는 actor의 executor에 격리되게 된다.
- 외부에서는 actor 내부 상태에 직접 접근이 불가하다.

```swift
actor UserStore {
    var users: [String] = []
}


let store = UserStore()
// ❌ 컴파일 에러
store.users.append("Jihoon")
```

이 상황에서 아래 처럼 해야한다.

```swift
actor UserStore {
    private var users: [String] = []


    func add(_ user: String) {
        users.append(user)
    }
}


await store.add("Jihoon")
```
이 구조 덕분에 데이터 레이스는 구조적으로 불가능합니다.

### Actor vs Class + Lock

기존에는 Class 와 NSLock을 사용해서

```swift
final class SafeCounter {
    private var value = 0
    private let lock = NSLock()

    func increment() {
        lock.lock()
        value += 1
        lock.unlock()
    }
}
```
문제점
- lock 누락 가능성
- 데드락 위험
- 가독성 저하
- 테스트 난이도 상승


Actor 방식을 사용하면
```swift
actor SafeCounter {
    private var value = 0

    func increment() {
        value += 1
    }
}
```

안정성과 가독성을 올리고, 컴파일러를 보장합니다.

### Non-isolated & Read-only 최적화

Actor의 모든 메ㅅ드가 항상 `await` 를 요구하는건 아니다.

```swift
actor Config {
    let apiVersion = "v1"


    nonisolated func version() -> String {
        apiVersion
    }
}
```

- `let` 상수는 동기화가 불필요
- `nonisolated`는 actor executor를 거치지 않음
- 성능 최적화에 매우 중요
- mutable state 접근은 불가

### Reentrancy (재진입성)
Actor는 reentrant하다.

```swift
actor BankAccount {
    var balance: Int = 100

    func withdraw(_ amount: Int) async {
        if balance >= amount {
            await Task.yield()
            balance -= amount
        }
    }
}
```

문제는, `await` 중에 다른 task가 끼어들 수 있고, 논리적 경쟁 상태 (logical race) 발생 가능합니다.
이를 해결하려면, 중요한 연산은 `await` 없이 한 번에 처리하며, State snapshot 사용하면 된다.
```swift
func withdraw(_ amount: Int) {
    guard balance >= amount else { return }
    balance -= amount
}
```
 
### Global Actor (MainActor)
```swift
@MainActor
class ViewModel {
    var title = ""
}
```

특정 executor(주로 Main Thread)에 격리 시킬수 있습니다.

### 성능
Actor같은 경우
- lock 기반 보다 약간 오버헤드가 존재
- context switching 비용
- executor enqueue/dequeue

하지만
- 대부분의 앱에서 체감 불가 수준
- lock 사용에 대한 버그 비용보다는 오버헤드가 감수 할 정도

Actor를 사용하면 안되는 경우
- 초당 수십만번 호출 되는 hot path 경우
- 매우 짧은 atomic 연산

대신 
`ManagedAtomic` (Swift Atomics)와 value type + task-local 로 처리 하면 됩니다.

### 언제 사용해야되나

- 공유 상태 관리
- cache, store, repository
- Analytics, Logging
- ViewModel, Domain Service


### 피해야되는 경우
- 수치 연산 중심 코드
- tight looop
- 단일 스레드 보장 환경
