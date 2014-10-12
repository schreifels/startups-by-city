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
    var wasExpanded = $this.hasClass('expanded');
    $this.parents('ul:eq(0)').find('.expanded').removeClass('expanded');
    if (!wasExpanded) $this.addClass('expanded');
  });
});
