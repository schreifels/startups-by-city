$(function() {
  $('#sidebar').find('.expandable').click(function(e) {
    e.preventDefault();
    $this = $(this);
    var wasExpanded = $this.hasClass('expanded');
    $this.parents('ul:eq(0)').find('.expanded').removeClass('expanded');
    if (!wasExpanded) $this.addClass('expanded');
  });
});
