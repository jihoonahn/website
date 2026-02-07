---
title: Universal Framework
date: 2023-4-2 18:30
tags: Swift, Framework
image: thumbnail/universal-framework.svg
description: Universal Framework에 대한 공부
---

## Universal Framework (범용 프레임워크)

디바이스와 시뮬레이터에서 사용가능하도록 범용적으로 프레임워크를 만드는 것입니다. <br/>
Device에서의 OS, SimulatorOS 둘 모두에 적용하기 위해서는 Valid Architecture가 모두 존재해야합니다.
iPhone OS에서의 CPU와, macOS에서의 경우 시뮬레이터의 구동을 위해서는 macOS의 CPU가 구현되어 맞춰줘야 합니다. <br/>

이러한 문제점을 해결하기 위해서 나온 것이 Universal Framework입니다. <br/>

### Universal Framework 의 장점

- 코드 재사용성이 올라간다.
- 코드 숨기가 쉬워진다.
- 코드 모듈화에 이점을 갖는다.
- 쉬운 통합이 가능하다.
- 쉽게 배포할 수 있다.

### 사용법

Target 아래쪽에 있는 + 버튼을 누릅니다. 그 후 Other -> Aggregate를 추가합니다. (Framework와 XCFramework 둘다 생성해줍니다.)

<img width="100%" src="https://user-images.githubusercontent.com/68891494/230734262-75b7f72f-2fcb-4e3c-b4ab-540aef965dbe.png"></img>

<img width="100%" src="https://user-images.githubusercontent.com/68891494/230734362-64553040-5617-4c18-88b3-fda6d5e38cdc.png"></img>

<img width="100%" src="https://user-images.githubusercontent.com/68891494/230734363-8b0e9098-a026-4ed1-8ef8-aa298ecf3c5c.png"></img>
<br/>

## Add Script

각각의 Aggregate에 Script를 추가해줍니다.

<img width="100%" src="https://user-images.githubusercontent.com/68891494/230735301-2f7b56e2-f9d7-4265-b4a6-53f4faa975f2.png"></img>
<img width="100%" src="https://user-images.githubusercontent.com/68891494/230735305-e7f7eb72-bdec-4032-af50-554bdc78fafb.png"></img>

#### XCFramework

```shell
# Build Device and Simulator versions
xcodebuild archive -scheme "${PROJECT_NAME}" -archivePath "${BUILD_DIR}/iphoneos.xcarchive" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme "${PROJECT_NAME}" -archivePath "${BUILD_DIR}/iphonesimulator.xcarchive" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
    -framework "${BUILD_DIR}/iphoneos.xcarchive/Products/Library/Frameworks/"${PROJECT_NAME}".framework" \
    -framework "${BUILD_DIR}/iphonesimulator.xcarchive/Products/Library/Frameworks/"${PROJECT_NAME}".framework" \
    -output "${BUILD_DIR}/"${PROJECT_NAME}".xcframework"


# Copy the xcframework to the project directory
cp -R "${BUILD_DIR}/"${PROJECT_NAME}".xcframework" "${PROJECT_DIR}"

# Open the project directory in Finder
open "${PROJECT_DIR}"
```

#### Framework

```
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-Universal

# Make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Build Device and Simulator versions
xcodebuild -target "${PROJECT_NAME}" BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${PROJECT_NAME}" BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build


# Copy the framework structure (from iphoneos build) to the universal folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"

# Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/." "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"

# Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}" -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# Copy the framework to the project directory
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${PROJECT_DIR}"

# Open the project directory in Finder
open "${PROJECT_DIR}"
```

<br/>

## Run

<img width="100%" src="https://user-images.githubusercontent.com/68891494/230735382-bb57dcae-094d-41fd-bbac-a67d58238720.png"></img>

각각 원하는 Aggregate Scheme를 선택하고 빌드하면 됩니다.

<img width="100%" src="https://user-images.githubusercontent.com/68891494/230735710-e91d3125-07ac-4725-a878-64c378dcfa28.png"></img>
<img width="100%" src="https://user-images.githubusercontent.com/68891494/230735711-ad3a28d2-a6c9-4d8f-a44a-b6ac63ebfaa8.png"></img>

좌 Framework Aggregate로 빌드 했을 때, 우 XCFramework Aggregate로 빌드 했을 때
<br/>

## Reference

- [tistory](https://magicmon.tistory.com/225)
- [medium](https://medium.com/macoclock/swift-universal-framework-3bc858224a7c)
- [kstenerud/iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework)
