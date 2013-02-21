//= require jquery
//= require bootstrap-tab
//= require_self
$(function() {
  reload_tables();
  reload_scoreboard();
  var refresh = getURLParameter("refresh");
  var delay = (getURLParameter("delay") == "pete" ? 1000 : 10000);
  if(refresh == "true") {
    setInterval(function() { reload_tables(); }, delay);
    setInterval(function() { reload_scoreboard(); }, 5000);
  }
})
function reload_tables() {
  $.ajax({
    url: '/tournaments/refresh',
    type: 'POST',
    success: function(e) {
      console.log(e);
    }
  });
}
function reload_scoreboard() {

}
function getURLParameter(name) {
  return decodeURI(
    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
  );
}
