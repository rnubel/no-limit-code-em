//= require jquery
//= require bootstrap-tab
//= require_self

$(function() {
  // refresh the data
  setInterval(function() {
    $('.loader').fadeIn();
    $.ajax({
      url: '/tournaments/refresh',
      type: 'GET',
      success: function() {
        $('.loader').fadeOut();
      }
    });
  }, 7000);
})

