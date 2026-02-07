import Foundation
import Web
import Generator

/// Posts / Projects 등 공통 상세 페이지 레이아웃. 백 버튼 경로와 하단 네비(선택)만 다르게 넣으면 됨.
struct ContentDetailLayout: HTMLConvertable {
    let post: Post
    let allPosts: [Post]
    let backPath: String
    /// nil이면 하단 Preview(이전/다음) 미표시
    let bottomNavigation: Component?

    var metadata: SiteMetaData {
        SiteMetaData(
            title: post.metadata.title,
            description: String(post.content.prefix(150))
        )
    }

    func build() -> HTML {
        Layout(metadata: metadata) {
            Main {
                Div {
                    Div {
                        Div {
                            Div {
                                Link(url: backPath) {
                                    BackIcon()
                                }
                                .class("flex items-center justify-center hover:bg-neutral-800 hover:text-neutral-400 rounded-full transition-colors duration-200 text-neutral-600 w-12 h-12")
                            }
                            .class("bg-black rounded-full border border-neutral-800 p-2")
                        }
                        .class("flex gap-3 mb-8")
                    }
                    .class("px-6 mx-auto max-w-2xl")
                    Div {
                        Div {
                            Time {
                                Text(post.metadata.date.formatDate())
                            }
                            .class("font-regular text-gray-500 text-sm")
                        }
                        .class("my-5 text-center")
                        H1(post.metadata.title)
                        .class("text-3xl font-bold mb-4 text-center")
                        Paragraph(post.metadata.description ?? "")
                            .class("text-base leading-relaxed text-center")
                    }
                    .class("max-w-2xl mx-auto px-6")
                    if !post.metadata.screens.isEmpty {
                        Div {
                            Div {
                                Div {
                                    ComponentGroup(members: post.metadata.screens.map { url in
                                        Div {
                                            Image(url: url, description: post.metadata.title)
                                                .class("screen-carousel-img")
                                        }
                                        .class("screen-carousel-slide")
                                    })
                                }
                                .class("screen-carousel-strip")
                                .id("screen-carousel-strip")
                                .attribute(named: "style", value: "--screen-count: \(post.metadata.screens.count)")
                            }
                            .class("screen-carousel-viewport")
                            Div {
                                Div {
                                    ComponentGroup(members: (0..<post.metadata.screens.count).map { i in
                                        Button {
                                            Text("")
                                        }
                                        .class("screen-carousel-dot" + (i == 0 ? " is-active" : ""))
                                        .attribute(named: "type", value: "button")
                                        .attribute(named: "data-index", value: String(i))
                                        .attribute(named: "aria-label", value: "Slide \(i + 1)")
                                    })
                                }
                                .class("screen-carousel-dots")
                                Span {
                                    Text("슬라이드 하면서 페이지 보여줌")
                                }
                                .class("screen-carousel-caption")
                            }
                            .class("screen-carousel-footer")
                        }
                        .class("screen-carousel max-w-4xl mx-auto px-6 mb-8")
                    } else if let image = post.metadata.image {
                        Div {
                            Figure {
                                Image(image)
                                    .class("p-0 w-full h-full object-cover")
                            }
                            .class("rounded-xl overflow-hidden")
                        }
                        .class("max-w-4xl mx-auto p-6")
                    }
                    Div {
                        Node<Any>.raw(post.htmlContent)
                    }
                    .class("markdown-content mx-auto max-w-2xl px-6 text-left")

                    if let nav = bottomNavigation {
                        Div {
                            nav
                        }
                        .class("max-w-2xl mx-auto px-6")
                    }
                }
                Script(
                    Text("""
                    document.addEventListener('DOMContentLoaded', function() {
                        var viewport = document.querySelector('.screen-carousel-viewport');
                        var strip = document.getElementById('screen-carousel-strip');
                        var dots = document.querySelectorAll('.screen-carousel-dot');
                        if (viewport && strip && dots.length) {
                            function goTo(i) {
                                var w = viewport.offsetWidth;
                                viewport.scrollLeft = i * w;
                                dots.forEach(function(d, j) {
                                    d.classList.toggle('is-active', j === i);
                                });
                            }
                            dots.forEach(function(dot, i) {
                                dot.addEventListener('click', function() { goTo(i); });
                            });
                            viewport.addEventListener('scroll', function() {
                                var i = Math.round(viewport.scrollLeft / viewport.offsetWidth);
                                i = Math.max(0, Math.min(i, dots.length - 1));
                                dots.forEach(function(d, j) { d.classList.toggle('is-active', j === i); });
                            });
                        }
                        var codeBlocks = document.querySelectorAll('.markdown-content pre');
                        codeBlocks.forEach(function(pre) {
                            var copyButton = document.createElement('button');
                            copyButton.textContent = 'Copy';
                            copyButton.className = 'copy-code-button';
                            copyButton.addEventListener('click', function() {
                                var codeElement = pre.querySelector('code');
                                var codeText = codeElement ? codeElement.textContent : pre.textContent;
                                navigator.clipboard.writeText(codeText).then(function() {
                                    copyButton.textContent = 'Copied!';
                                    setTimeout(function() { copyButton.textContent = 'Copy'; }, 1500);
                                }).catch(function() {
                                    var textArea = document.createElement('textarea');
                                    textArea.value = codeText;
                                    document.body.appendChild(textArea);
                                    textArea.select();
                                    document.execCommand('copy');
                                    document.body.removeChild(textArea);
                                    copyButton.textContent = 'Copied!';
                                    setTimeout(function() { copyButton.textContent = 'Copy'; }, 1500);
                                });
                            });
                            pre.appendChild(copyButton);
                        });
                    });
                    """)
                )
            }
            .class("min-h-screen pb-24 pt-32")
        }
        .build()
    }
}
