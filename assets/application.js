$(function() {
  $('#content').find('tbody tr').click(function(e) {
    if (e.target.tagName.toLowerCase() !== 'a') {
      e.preventDefault()
      window.open($(e.target).closest('tr').find('a:eq(0)').prop('href'));
    }
  });

  $('#sidebar').find('.expandable').click(function(e) {
    e.preventDefault();
    $this = $(this);

    if (window.matchMedia('(max-width: 767px)').matches) {
      var wasExpanded = $this.is('.expanded:not(.auto-expanded)');
    } else {
      var wasExpanded = $this.hasClass('expanded');
    }

    $this.parents('ul:eq(0)').find('.expanded, .auto-expanded').removeClass('expanded auto-expanded');
    if (!wasExpanded) $this.addClass('expanded');
  });
});
