document.addEventListener('DOMContentLoaded', function() {
    var root = document.querySelector('.project-mockup-main');
    if (!root) return;
    var mockup = document.getElementById('project-device-mockup');
    var row = root.querySelector('.project-mockup-device-row');
    var tabs = root.querySelectorAll('.project-mockup-tab');
    var typeEl = document.getElementById('project-mockup-type');

    if (mockup && row && tabs.length) {
        tabs.forEach(function(tab) {
            tab.addEventListener('click', function() {
                var platform = tab.getAttribute('data-platform');
                var subtitle = tab.getAttribute('data-subtitle');
                if (!platform) return;
                tabs.forEach(function(t) { t.classList.remove('is-active'); });
                tab.classList.add('is-active');
                mockup.setAttribute('data-platform', platform);
                mockup.className = 'device-mockup device-mockup--' + platform;
                row.setAttribute('data-current-platform', platform);
                if (typeEl && subtitle) typeEl.textContent = subtitle;
            });
        });
    }

    var viewports = root.querySelectorAll('.device-carousel-viewport');
    viewports.forEach(function(viewport) {
        var platform = viewport.getAttribute('data-platform');
        if (!platform) return;
        var dots = root.querySelectorAll('.device-carousel-dots[data-platform="' + platform + '"] .device-carousel-dot');
        if (dots.length === 0) return;

        function slideWidth() {
            var slide = viewport.querySelector('.device-carousel-slide');
            return (slide && slide.offsetWidth) ? slide.offsetWidth : viewport.offsetWidth;
        }
        function updateDotsFromScroll() {
            var w = slideWidth();
            if (w <= 0) return;
            var i = Math.round(viewport.scrollLeft / w);
            i = Math.max(0, Math.min(i, dots.length - 1));
            for (var j = 0; j < dots.length; j++) dots[j].classList.toggle('is-active', j === i);
        }
        function goTo(i) {
            var w = slideWidth();
            viewport.scrollLeft = i * w;
            for (var j = 0; j < dots.length; j++) dots[j].classList.toggle('is-active', j === i);
        }
        for (var i = 0; i < dots.length; i++) {
            (function(idx) { dots[idx].addEventListener('click', function() { goTo(idx); }); })(i);
        }
        viewport.addEventListener('scroll', updateDotsFromScroll);
        viewport.addEventListener('touchmove', updateDotsFromScroll);
        try { viewport.addEventListener('scrollend', updateDotsFromScroll); } catch (e) {}
        setTimeout(updateDotsFromScroll, 150);
        requestAnimationFrame(updateDotsFromScroll);
    });

    var codeBlocks = root.querySelectorAll('.project-mockup-content pre');
    codeBlocks.forEach(function(pre) {
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
