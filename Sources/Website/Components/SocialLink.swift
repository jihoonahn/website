import Web

struct SocialLink: Component {
    let title: String
    let description: String
    let url: String
    let icon: Component
    
    var body: Component {
        Link(url: url) {
            Div {
                Div {
                    icon
                }
                .class("flex-shrink-0")
                
                Div {
                    H3(title)
                        .class("text-lg font-semibold text-white")
                    
                    Paragraph(description)
                        .class("text-sm text-white/80")
                }
                .class("flex-1 text-left")
                
                Div {
                    Text("→")
                        .class("text-white/60 text-xl")
                }
                .class("flex-shrink-0")
            }
            .class("flex items-center gap-4 px-6 py-4")
        }
        .class("bg-black border border-neutral-800 block w-full rounded-full")
    }
}

