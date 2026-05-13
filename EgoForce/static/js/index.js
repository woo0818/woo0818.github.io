window.HELP_IMPROVE_VIDEOJS = false;

$(document).ready(function() {
    // Mobile nav burger
    $(".navbar-burger").click(function() {
      $(".navbar-burger").toggleClass("is-active");
      $(".navbar-menu").toggleClass("is-active");
    });

    // Bulma carousels
    var options = {
        slidesToScroll: 1, slidesToShow: 3, loop: true, infinite: true,
        autoplay: false, autoplaySpeed: 3000,
    };
    bulmaCarousel.attach('.carousel', options);
    if (window.bulmaSlider) { bulmaSlider.attach(); }

    // Lazy-play videos: only fetch+play when in viewport
    var videos = document.querySelectorAll('video');
    videos.forEach(function (v) {
      v.removeAttribute('autoplay');
      if (!v.hasAttribute('preload')) v.setAttribute('preload', 'metadata');
      v.muted = true;
    });
    if ('IntersectionObserver' in window) {
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (e) {
          if (e.isIntersecting) {
            e.target.play().catch(function () {});
          } else {
            e.target.pause();
          }
        });
      }, { threshold: 0.15, rootMargin: '200px 0px' });
      videos.forEach(function (v) { io.observe(v); });
    } else {
      videos.forEach(function (v) { v.play().catch(function () {}); });
    }

    // Defer images (skip if author set explicit eager loading)
    document.querySelectorAll('img').forEach(function (img) {
      if (!img.hasAttribute('loading')) img.setAttribute('loading', 'lazy');
      if (!img.hasAttribute('decoding')) img.setAttribute('decoding', 'async');
    });
});
