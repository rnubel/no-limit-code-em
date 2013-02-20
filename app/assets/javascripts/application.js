//= require jquery
//= require bootstrap-tab
//= require_self

$(function() {
  reload_page();

  var refresh = getURLParameter("refresh");
  if(refresh == "true") {
    setInterval(function() {
      reload_page();
    }, 1000);
  }
})

function reload_page() {
  $('.loader').fadeIn();
  $.ajax({
    url: '/tournaments/refresh',
    type: 'GET',
    success: function() {
      $('.loader').fadeOut();
    }
  });
}

function getURLParameter(name) {
    return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    );
}
