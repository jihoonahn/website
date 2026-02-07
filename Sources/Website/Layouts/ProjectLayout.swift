import Foundation
import Web
import Generator

/// 프로젝트 상세 페이지 레이아웃. 플랫폼 탭, 디바이스 목업, 닫기 버튼 포함.
struct ProjectLayout: HTMLConvertable {
    let post: Post
    let allPosts: [Post]

    var metadata: SiteMetaData {
        SiteMetaData(
            title: post.metadata.title,
            description: post.metadata.description ?? String(post.content.prefix(150))
        )
    }

    private var platforms: [(key: String, label: String, subtitle: String)] {
        let hasPlatforms = post.metadata.platforms.contains { ["iOS", "iPad", "macOS"].contains($0) }
        let list = hasPlatforms ? post.metadata.platforms : ["iOS"]
        return list.compactMap { p -> (String, String, String)? in
            switch p {
            case "iOS": return ("ios", "iOS", "iOS App")
            case "iPad": return ("ipad", "iPad", "iPad App")
            case "macOS": return ("mac", "macOS", "macOS App")
            default: return nil
            }
        }
    }

    private var defaultPlatformKey: String {
        platforms.first?.key ?? "ios"
    }

    func build() -> HTML {
        Layout(metadata: metadata) {
            Main {
                Div {
                    Div {
                        Div {
                            Link(url: "/projects") {
                                BackIcon()
                            }
                            .class("flex items-center justify-center hover:bg-neutral-800 hover:text-neutral-400 rounded-full transition-colors duration-200 text-neutral-600 w-12 h-12")
                        }
                        .class("bg-black rounded-full border border-neutral-800 p-2")
                    }
                    .class("flex gap-3 mb-8")

                    Div {
                        // 좌측: 플랫폼 탭, 제목, 유형, 설명
                        Div {
                            if !platforms.isEmpty {
                                Div {
                                    ComponentGroup(members: platforms.enumerated().map { i, p in
                                        Button {
                                            Text(p.label)
                                        }
                                        .class("project-mockup-tab" + (i == 0 ? " is-active" : ""))
                                        .attribute(named: "type", value: "button")
                                        .attribute(named: "data-platform", value: p.key)
                                        .attribute(named: "data-subtitle", value: p.subtitle)
                                        .attribute(named: "aria-label", value: "\(p.label) 보기")
                                    })
                                }
                                .class("project-mockup-tabs")
                            }

                            H1(post.metadata.title)
                                .class("project-mockup-title")

                            Span {
                                Text(platformSubtitle(for: defaultPlatformKey))
                            }
                            .id("project-mockup-type")
                            .class("project-mockup-type")

                            if let desc = post.metadata.description, !desc.isEmpty {
                                Paragraph(desc)
                                    .class("project-mockup-desc")
                            }
                        }
                        .class("project-mockup-info")

                        // 우측: 디바이스 목업 + 세로 도트 네비게이션 (이미지 시안 내비게이션 위치)
                        Div {
                            Div {
                                Div {
                                    deviceMockup()
                                }
                                .id("project-device-mockup")
                                .class("device-mockup device-mockup--\(defaultPlatformKey)")
                                .attribute(named: "data-platform", value: defaultPlatformKey)

                                ComponentGroup(members: platforms.map { p in
                                    carouselDots(for: p.key)
                                })
                            }
                            .class("project-mockup-device-row")
                            .attribute(named: "data-current-platform", value: defaultPlatformKey)

                            Span {
                                Text("슬라이드 하면서 페이지 보여줌")
                            }
                            .class("device-carousel-caption")
                        }
                        .class("project-mockup-device")
                    }
                    .class("project-mockup-wrap")

                    // 마크다운 콘텐츠
                    Div {
                        Node<Any>.raw(post.htmlContent)
                    }
                    .class("project-mockup-content markdown-content")
                }
                .class("project-mockup-main min-h-screen pt-24 pb-24")

                Script()
                    .attribute(named: "src", value: "/scripts/project-mockup.js")
                copyCodeScript()
            }
            .class("min-h-screen pb-24 pt-32")
        }
        .build()
    }

    private func platformSubtitle(for key: String) -> String {
        platforms.first { $0.key == key }?.subtitle ?? "App"
    }

    private func deviceMockup() -> Component {
        Div {
            ComponentGroup(members: platforms.map { p in
                let screens = post.metadata.screens(forPlatformKey: p.key)
                let count = max(1, screens.count)
                return Div {
                    Div {
                        ComponentGroup(members: screens.isEmpty
                            ? [placeholderSlide()]
                            : screens.map { url in
                                Div {
                                    Image(url: url, description: post.metadata.title)
                                        .class("device-carousel-img")
                                }
                                .class("device-carousel-slide")
                            }
                    )
                    }
                    .class("device-carousel-strip")
                    .attribute(named: "style", value: "--screen-count: \(count)")
                }
                .class("device-carousel-viewport")
                .attribute(named: "data-platform", value: p.key)
            })
        }
        .class("device-mockup__screen")
    }

    private func placeholderSlide() -> Component {
        Div {
            if let img = post.metadata.image {
                Image(url: img, description: post.metadata.title)
                    .class("device-carousel-img")
            } else {
                Span {
                    Text(String(post.metadata.title.prefix(1)))
                }
                .class("text-4xl font-semibold text-neutral-500")
            }
        }
        .class("device-carousel-slide")
    }

    private func carouselDots(for platformKey: String) -> Component {
        let screens = post.metadata.screens(forPlatformKey: platformKey)
        let count = max(1, screens.count)
        return Div {
            ComponentGroup(members: (0..<count).map { i in
                Button {
                    Text("")
                }
                .class("device-carousel-dot" + (i == 0 && platformKey == defaultPlatformKey ? " is-active" : ""))
                .attribute(named: "type", value: "button")
                .attribute(named: "aria-label", value: "슬라이드 \(i + 1)")
            })
        }
        .class("device-carousel-dots")
        .attribute(named: "data-platform", value: platformKey)
    }

    private func copyCodeScript() -> Component {
        Script(
            Text("""
            document.addEventListener('DOMContentLoaded', function() {
                var blocks = document.querySelectorAll('.markdown-content pre');
                blocks.forEach(function(pre) {
                    var btn = document.createElement('button');
                    btn.textContent = 'Copy';
                    btn.className = 'copy-code-button';
                    btn.addEventListener('click', function() {
                        var code = pre.querySelector('code');
                        var text = code ? code.textContent : pre.textContent;
                        navigator.clipboard.writeText(text).then(function() {
                            btn.textContent = 'Copied!';
                            setTimeout(function() { btn.textContent = 'Copy'; }, 1500);
                        });
                    });
                    pre.appendChild(btn);
                });
            });
            """)
        )
    }
}
