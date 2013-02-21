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
    type: 'GET',
    success: function(e) {
      console.log(e);
    }
  });
}
function reload_scoreboard() {

}
function table(hash) {
  number = hash.table_id;
  players = hash.players
  count = 0;
  html = "<div class='poker_table'>
            <h3>
              <div class='pull_left'>Table " + number + "</div>
              <div class='clearfix'></div>
            </h3>
            <table class='players'>
              <tr>";
  $.each(players, function(player) {
    count += 1;
    if(count == 3)
    html += "<td" + bottom ">
              <span class='name'>" + player.name + "</span>
              <span class='stack'>" + player.name + "</span>
            </td>"

  });

}
function getURLParameter(name) {
  return decodeURI(
    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
  );
}
