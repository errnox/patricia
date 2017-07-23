$(document).ready(function() {
  // Tooltips

  $('#toc li span, #toc li a').each(function() {
    $(this).attr('data-toggle', 'tooltip');
    $(this).attr('data-placement', 'left');
  });
  $('[data-toggle=tooltip]').tooltip();

});
