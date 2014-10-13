$(function() {
  $('#content').find('tbody tr').click(function(e) {
    if (e.target.tagName.toLowerCase() !== 'a') {
      e.preventDefault()
      window.open($(e.target).closest('tr').find('a:eq(0)').prop('href'));
    }
  });

  $window = $(window);

  $('#sidebar').find('.expandable').click(function(e) {
    var wasExpanded, targetTop;

    e.preventDefault();
    $this = $(this);

    if (window.matchMedia('(max-width: 767px)').matches) {
      wasExpanded = $this.is('.expanded:not(.auto-expanded)');
    } else {
      wasExpanded = $this.hasClass('expanded');
    }

    $this.parents('ul:eq(0)').find('.expanded, .auto-expanded').removeClass('expanded auto-expanded');
    if (!wasExpanded) $this.addClass('expanded');

    // Prevent the accordian from hiding the nav item we just clicked into
    targetTop = $this.offset().top;
    if ($window.scrollTop() > (targetTop + $this.height())) {
      window.scrollTo(0, targetTop - 10);
    }
  });
});
