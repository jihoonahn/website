import Web
import Generator

@HTMLBuilder
func index() -> HTML {
    let metadata = SiteMetaData()

    Layout(metadata: metadata) {
        Main {
            Div {
                Div {
                    Div()
                        .class("w-10 h-10 border-2 border-neutral-600 border-t-neutral-400 rounded-full animate-spin")
                    Span { Text("Loading") }
                        .class("mt-3 text-neutral-500 text-sm")
                }
                .id("portfolio-loading")
                .class("flex flex-col items-center justify-center py-24")

                Div { }
                    .id("index-content")
                    .class("index-content hidden")
                    .attribute(named: "aria-live", value: "polite")
            }
            .class("index-main-inner max-w-2xl mx-auto px-5 pt-28 pb-20 min-h-screen")
            .id("index-main")

            Script {
                Node<Any>.raw("""
                document.addEventListener('DOMContentLoaded', function() {
                    var content = document.getElementById('index-content');
                    var loading = document.getElementById('portfolio-loading');
                    if (!content || !loading) return;

                    var base = window.location.pathname.replace(/\\/index\\.html?$/i, '/').replace(/[^/]+$/, '') || '/';
                    if (!base.endsWith('/')) base += '/';
                    fetch(base + 'portfolio.json')
                        .then(function(r) { return r.ok ? r.json() : null; })
                        .then(function(data) {
                            loading.classList.add('hidden');
                            content.classList.remove('hidden');
                            if (!data || !data.projects || data.projects.length === 0) {
                                content.innerHTML = '<p class="text-neutral-500 text-center py-12">No projects.</p>';
                                return;
                            }
                            var projects = data.projects;
                            var groups = {};
                            projects.forEach(function(p) {
                                var g = (p.group || p.category || '프로젝트').trim();
                                if (!groups[g]) groups[g] = [];
                                groups[g].push(p);
                            });
                            var widgetGroup = groups['위젯'] || [];
                            var appGroup = groups['App'] || [];
                            var opensourceGroup = groups['Opensource'] || [];
                            var speakerGroup = groups['Speaker'] || [];
                            var github = data.github;
                            var githubUser = (typeof github === 'string') ? github : (github && github.owner ? github.owner : '');
                            var html = '<div class="index-home">';
                            html += '<section class="index-widgets" aria-label="위젯">';
                            html += '<div class="index-widget-grid">';
                            html += '<div class="index-widget-card index-widget-clock" aria-label="현재 시각">';
                            html += '<span class="index-widget-clock-time" id="index-widget-clock-time">00:00</span>';
                            html += '<span class="index-widget-clock-date" id="index-widget-clock-date">-</span>';
                            html += '</div>';
                            html += '<div class="index-widget-card index-widget-social" aria-label="Social">';
                            html += '<div class="index-widget-social-btns">';
                            html += '<a href="https://github.com/jihoonahn" class="index-widget-social-btn" target="_blank" rel="noopener" aria-label="GitHub"><svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.87 8.17 6.84 9.5.5.08.66-.23.66-.5v-1.69c-2.77.6-3.36-1.34-3.36-1.34-.46-1.16-1.11-1.47-1.11-1.47-.91-.62.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.87 1.52 2.34 1.07 2.91.83.09-.65.35-1.09.63-1.34-2.22-.25-4.55-1.11-4.55-4.92 0-1.11.38-2 1.03-2.71-.1-.25-.45-1.29.1-2.64 0 0 .84-.27 2.75 1.02.79-.22 1.65-.33 2.5-.33.85 0 1.71.11 2.5.33 1.91-1.29 2.75-1.02 2.75-1.02.55 1.35.2 2.39.1 2.64.65.71 1.03 1.6 1.03 2.71 0 3.82-2.34 4.66-4.57 4.91.36.31.69.92.69 1.85V21c0 .27.16.59.67.5C19.14 20.16 22 16.42 22 12A10 10 0 0012 2z"/></svg></a>';
                            html += '<a href="https://www.linkedin.com/in/ahnjihoon/" class="index-widget-social-btn" target="_blank" rel="noopener" aria-label="LinkedIn"><svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg></a>';
                            html += '<a href="mailto:jihoonahn.dev@gmail.com" class="index-widget-social-btn" target="_blank" rel="noopener" aria-label="Email"><svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" clip-rule="evenodd" d="M4 7C4 6.44772 4.44772 6 5 6H19C19.5523 6 20 6.44772 20 7V17C20 17.5523 19.5523 18 19 18H5C4.44772 18 4 17.5523 4 17V7zM5.3 8.01V16.7h13.4V8.01L12 11.11 5.3 8.01zM17.46 7.3H6.54l5.26 3.76c.12.09.28.09.4 0L17.46 7.3z"/></svg></a>';
                            html += '</div></div>';
                            widgetGroup.forEach(function(p, i) {
                                var img = p.image ? '<img src="' + esc(p.image) + '" alt="" loading="' + (i < 4 ? 'eager' : 'lazy') + '" class="index-widget-icon">' : '';
                                var href = (p.url || '').indexOf('http') === 0 ? p.url : base.replace(/\\/$/, '') + (p.url && p.url[0] === '/' ? p.url : '/' + (p.url || ''));
                                var ext = (p.url || '').indexOf('http') === 0;
                                html += '<a href="' + esc(href) + '" class="index-widget-card"' + (ext ? ' target="_blank" rel="noopener"' : '') + '>';
                                html += '<span class="index-widget-icon-wrap">' + (img || '<span class="index-widget-letter">' + (p.title ? p.title[0] : '') + '</span>') + '</span>';
                                html += '<span class="index-widget-title">' + esc(p.title || '') + '</span>';
                                if (p.description) html += '<span class="index-widget-desc">' + esc(p.description) + '</span>';
                                html += '</a>';
                            });
                            html += '</div></section>';
                            if (githubUser) {
                                html += '<section class="index-github-wrap" id="index-github-wrap" aria-label="GitHub 잔디">';
                                html += '<a href="https://github.com/' + encodeURIComponent(githubUser) + '" class="index-github-grass-link" target="_blank" rel="noopener">';
                                html += '<div class="index-folder index-github index-github-grass">';
                                html += '<div class="index-github-grass-grid" id="index-github-grass-grid"></div>';
                                html += '</div></a></section>';
                            }
                            if (appGroup.length > 0) {
                                var numChunks = Math.ceil(appGroup.length / 9);
                                html += '<section class="index-app-group-wrap" aria-label="App">';
                                html += '<h2 class="index-section-title">App</h2>';
                                html += '<div class="index-folder index-app-group">';
                                html += '<div class="index-app-group-pages">';
                                html += '<div class="index-app-group-scroll" id="index-app-group-scroll">';
                                html += '<div class="index-app-group-strip" id="index-app-group-strip">';
                                for (var chunkStart = 0; chunkStart < appGroup.length; chunkStart += 9) {
                                    html += '<div class="index-app-group-page">';
                                    html += '<div class="index-app-group-grid">';
                                    for (var j = 0; j < 9 && chunkStart + j < appGroup.length; j++) {
                                        var p = appGroup[chunkStart + j];
                                        var img = p.image ? '<img src="' + esc(p.image) + '" alt="" loading="' + (chunkStart + j < 9 ? 'eager' : 'lazy') + '" class="index-app-icon-img">' : '';
                                        var href = (p.url || '').indexOf('http') === 0 ? p.url : base.replace(/\\/$/, '') + (p.url && p.url[0] === '/' ? p.url : '/' + (p.url || ''));
                                        var ext = (p.url || '').indexOf('http') === 0;
                                        html += '<a href="' + esc(href) + '" class="index-app-icon"' + (ext ? ' target="_blank" rel="noopener"' : '') + '>';
                                        html += '<span class="index-app-icon-box">' + (img || '<span class="index-app-icon-letter">' + (p.title ? p.title[0] : '') + '</span>') + '</span>';
                                        html += '<span class="index-app-icon-label">' + esc(p.title || '') + '</span>';
                                        html += '</a>';
                                    }
                                    html += '</div></div>';
                                }
                                html += '</div></div>';
                                html += '<div class="index-app-group-indicator" id="index-app-group-indicator">';
                                for (var k = 0; k < numChunks; k++) {
                                    html += '<button type="button" class="index-app-group-dot' + (k === 0 ? ' is-active' : '') + '" aria-label="Page ' + (k+1) + '" data-page="' + k + '"></button>';
                                }
                                html += '</div></div></div></section>';
                            }
                            if (opensourceGroup.length > 0) {
                                html += '<section class="index-opensource-wrap" aria-label="Opensource">';
                                html += '<h2 class="index-section-title">Opensource</h2>';
                                html += '<ul class="index-opensource-list" id="index-opensource-list">';
                                opensourceGroup.forEach(function(p) {
                                    var repo = (p.repo || '').trim();
                                    var title = p.title || repo;
                                    var repoUrl = repo ? ('https://github.com/' + repo) : '#';
                                    var starsText = (p.stars != null && p.stars !== undefined) ? (typeof p.stars === 'number' ? p.stars.toLocaleString() : String(p.stars)) : '-';
                                    var descText = (p.description && String(p.description).trim()) ? esc(String(p.description).trim()) : '-';
                                    html += '<li class="index-opensource-item">';
                                    html += '<a href="' + esc(repoUrl) + '" class="index-opensource-link" target="_blank" rel="noopener">';
                                    html += '<span class="index-opensource-title">' + esc(title) + '</span>';
                                    html += '<span class="index-opensource-meta"><span class="index-opensource-stars">' + starsText + '</span> stars</span>';
                                    html += '<span class="index-opensource-desc">' + descText + '</span>';
                                    html += '</a></li>';
                                });
                                html += '</ul></section>';
                            }
                            if (speakerGroup.length > 0) {
                                html += '<section class="index-speaker-wrap" aria-label="Speaker">';
                                html += '<h2 class="index-section-title">Speaker</h2>';
                                html += '<div class="index-speaker-grid">';
                                speakerGroup.forEach(function(p) {
                                    var href = (p.url || '').indexOf('http') === 0 ? p.url : base.replace(/\\/$/, '') + (p.url && p.url[0] === '/' ? p.url : '/' + (p.url || ''));
                                    var ext = (p.url || '').indexOf('http') === 0;
                                    html += '<a href="' + esc(href) + '" class="index-speaker-card"' + (ext ? ' target="_blank" rel="noopener"' : '') + '>';
                                    html += '<span class="index-speaker-title">' + esc(p.title || '') + '</span>';
                                    if (p.description) html += '<span class="index-speaker-desc">' + esc(p.description) + '</span>';
                                    if (p.date) html += '<span class="index-speaker-date">' + esc(p.date) + '</span>';
                                    html += '</a>';
                                });
                                html += '</div></section>';
                            }
                            html += '</div>';
                            content.innerHTML = html;
                            var timeEl = document.getElementById('index-widget-clock-time');
                            var dateEl = document.getElementById('index-widget-clock-date');
                            function updateClock() {
                                var now = new Date();
                                var h = now.getHours(), m = now.getMinutes();
                                if (timeEl) timeEl.textContent = (h < 10 ? '0' : '') + h + ':' + (m < 10 ? '0' : '') + m;
                                if (dateEl) {
                                    var mon = now.getMonth() + 1, d = now.getDate(), day = now.getDay();
                                    var dayNames = ['일','월','화','수','목','금','토'];
                                    dateEl.textContent = mon + '/' + d + ' ' + dayNames[day];
                                }
                            }
                            if (timeEl && dateEl) { updateClock(); setInterval(updateClock, 1000); }
                            (function initAppGroupScrollSnap() {
                                var scrollEl = document.getElementById('index-app-group-scroll');
                                var strip = document.getElementById('index-app-group-strip');
                                var indicator = document.getElementById('index-app-group-indicator');
                                if (!scrollEl || !strip || !indicator) return;
                                var pages = strip.querySelectorAll('.index-app-group-page');
                                var numChunks = pages.length;
                                if (numChunks <= 0) return;
                                strip.style.width = (numChunks * 100) + '%';
                                pages.forEach(function(pg) {
                                    pg.style.flexBasis = (100 / numChunks) + '%';
                                    pg.style.minWidth = (100 / numChunks) + '%';
                                });
                                function updateIndicator() {
                                    var w = scrollEl.offsetWidth;
                                    if (!w) return;
                                    var idx = Math.round(scrollEl.scrollLeft / w);
                                    idx = Math.max(0, Math.min(idx, numChunks - 1));
                                    indicator.querySelectorAll('.index-app-group-dot').forEach(function(dot, i) {
                                        dot.classList.toggle('is-active', i === idx);
                                    });
                                }
                                scrollEl.addEventListener('scroll', updateIndicator, { passive: true });
                                if (typeof scrollEl.onscrollend !== 'undefined') scrollEl.addEventListener('scrollend', updateIndicator, { passive: true });
                                updateIndicator();
                                indicator.querySelectorAll('.index-app-group-dot').forEach(function(dot) {
                                    dot.addEventListener('click', function() {
                                        var p = parseInt(dot.getAttribute('data-page'), 10);
                                        if (isNaN(p)) return;
                                        var pageWidth = scrollEl.offsetWidth;
                                        scrollEl.scrollTo({ left: p * pageWidth, behavior: 'smooth' });
                                    });
                                });
                            })();
                            var grassEl = document.getElementById('index-github-grass-grid');
                            if (grassEl && githubUser) {
                                window.__portfolioGitHubUser = githubUser;
                                fetch('https://gh-calendar.rschristian.dev/user/' + encodeURIComponent(githubUser))
                                    .then(function(r) { return r.ok ? r.json() : null; })
                                    .then(function(data) {
                                        var dayCount = {};
                                        if (data && data.contributions && Array.isArray(data.contributions)) {
                                            data.contributions.forEach(function(week) {
                                                if (Array.isArray(week)) {
                                                    week.forEach(function(day) {
                                                        if (day && day.date) dayCount[day.date] = parseInt(day.count, 10) || 0;
                                                    });
                                                }
                                            });
                                        }
                                        if (data && data.contributions) {
                                            renderGrass(dayCount);
                                            return;
                                        }
                                        tryGraphQL();
                                    })
                                    .catch(function() { tryGraphQL(); });
                            }
                            function tryGraphQL() {
                                var githubUser = window.__portfolioGitHubUser;
                                if (!githubUser) { tryFallbackEvents(); return; }
                                var totalDays = 371;
                                var toDate = new Date();
                                var fromDate = new Date(toDate);
                                fromDate.setDate(fromDate.getDate() - totalDays + 1);
                                var fromStr = fromDate.toISOString().slice(0,10) + 'T00:00:00Z';
                                var toStr = toDate.toISOString().slice(0,10) + 'T23:59:59Z';
                                var query = 'query($user: String!, $from: DateTime!, $to: DateTime!) { user(login: $user) { contributionsCollection(from: $from, to: $to) { contributionCalendar { weeks { contributionDays { date contributionCount } } } } } }';
                                fetch('https://api.github.com/graphql', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({ query: query, variables: { user: githubUser, from: fromStr, to: toStr } })
                                }).then(function(r) { return r.json(); }).then(function(res) {
                                    var dayCount = {};
                                    if (res.errors || !res.data || !res.data.user) { tryFallbackEvents(); return; }
                                    var cal = res.data.user.contributionsCollection && res.data.user.contributionsCollection.contributionCalendar;
                                    if (cal && cal.weeks) {
                                        cal.weeks.forEach(function(week) {
                                            if (week.contributionDays) {
                                                week.contributionDays.forEach(function(day) {
                                                    if (day.date) dayCount[day.date] = day.contributionCount || 0;
                                                });
                                            }
                                        });
                                    }
                                    renderGrass(dayCount);
                                }).catch(function() { tryFallbackEvents(); });
                            }
                            function tryFallbackEvents() {
                                var grassEl = document.getElementById('index-github-grass-grid');
                                var githubUser = (typeof (window.__portfolioGitHubUser) === 'string') ? window.__portfolioGitHubUser : '';
                                if (!grassEl || !githubUser) return;
                                Promise.all([fetch('https://api.github.com/users/' + encodeURIComponent(githubUser) + '/events?per_page=100').then(function(r) { return r.ok ? r.json() : []; }), fetch('https://api.github.com/users/' + encodeURIComponent(githubUser) + '/events?per_page=100&page=2').then(function(r) { return r.ok ? r.json() : []; })]).then(function(results) {
                                    var dayCount = {};
                                    (results[0] || []).concat(results[1] || []).forEach(function(ev) {
                                        if (ev.type !== 'PushEvent' || !ev.payload || !ev.created_at) return;
                                        var date = ev.created_at.slice(0, 10);
                                        var n = (ev.payload.commits && ev.payload.commits.length) ? ev.payload.commits.length : 1;
                                        dayCount[date] = (dayCount[date] || 0) + n;
                                    });
                                    renderGrass(dayCount);
                                }).catch(function() {});
                            }
                            function renderGrass(dayCount) {
                                var grassEl = document.getElementById('index-github-grass-grid');
                                if (!grassEl) return;
                                var totalDays = 371, cols = 53, rows = 7;
                                var toDate = new Date();
                                var fromDate = new Date(toDate);
                                fromDate.setDate(fromDate.getDate() - totalDays + 1);
                                var start = new Date(fromDate);
                                    start.setHours(0,0,0,0);
                                    var grid = [];
                                    for (var c = 0; c < cols; c++) { grid[c] = []; for (var r = 0; r < rows; r++) grid[c][r] = 0; }
                                    for (var i = 0; i < totalDays; i++) {
                                        var d = new Date(start);
                                        d.setDate(d.getDate() + i);
                                        var key = d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
                                        var count = dayCount[key] || 0;
                                        var weekIdx = Math.floor(i / 7);
                                        var dayIdx = d.getDay();
                                        if (weekIdx < cols) grid[weekIdx][dayIdx] = count;
                                    }
                                    var out = '';
                                    for (var row = 0; row < rows; row++) {
                                        out += '<div class="index-github-grass-row">';
                                        for (var col = 0; col < cols; col++) {
                                            var c = (grid[col] && grid[col][row] !== undefined) ? grid[col][row] : 0;
                                            var level = c <= 0 ? 0 : (c <= 3 ? 1 : (c <= 6 ? 2 : (c <= 9 ? 3 : 4)));
                                            out += '<span class="index-github-grass-cell" data-level="' + level + '"></span>';
                                        }
                                        out += '</div>';
                                    }
                                    grassEl.innerHTML = out;
                            }
                        })
                        .catch(function() {
                            loading.classList.add('hidden');
                            content.classList.remove('hidden');
                            content.innerHTML = '<p class="text-neutral-500 text-center py-12">Could not load portfolio.</p>';
                        });
                    function esc(s) {
                        if (!s) return '';
                        var d = document.createElement('div');
                        d.textContent = s;
                        return d.innerHTML;
                    }
                });
                """)
            }
        }
    }
}
