import Web

struct SocialMediaLink {
    let title: String
    let description: String
    let url: String
    let icon: Component
}

extension SocialMediaLink {
    static var linkedIn: SocialMediaLink {
        SocialMediaLink(
            title: "LinkedIn",
            description: "Follow my thoughts and updates",
            url: "https://www.linkedin.com/in/ahnjihoon/",
            icon: LinkedInIcon()
        )
    }
    static var github: SocialMediaLink {
        SocialMediaLink(
            title: "GitHub",
            description: "Check out my code and projects",
            url: "https://github.com/jihoonahn",
            icon: GitIcon()
        )
    }
    static var rss: SocialMediaLink {
        SocialMediaLink(
            title: "Rss",
            description: "My post feeds",
            url: "https://jihoon.me/feed.rss",
            icon: RssIcon()
        )
    }
    static var email: SocialMediaLink {
        SocialMediaLink(
            title: "Email",
            description: "Get in touch with me",
            url: "mailto:jihoonahn.dev@gmail.com",
            icon: MailIcon()
        )
    }
    static var resume: SocialMediaLink {
        SocialMediaLink(
            title: "Resume",
            description: "Download my CV",
            url: "https://docs.google.com/document/d/1qArX5-LgS29bvLyLMgvCfa5Pl9h8K0wh9RJln0oZClY/edit?usp=sharing",
            icon: TextAreaIcon()
        )
    }
}
