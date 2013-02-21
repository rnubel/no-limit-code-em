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
    url: '/tournaments/tables',
    type: 'GET',
    success: function(e) {
      $('#poker_tables').html("");
      $.each(e, function() {
        $('#poker_tables').append(table($(this)[0]))
      });
    }
  });
}
function reload_scoreboard() {
  $.ajax({
    url: '/tournaments/scoreboard',
    type: 'GET',
    success: function(e) {
    }
  });
}
function table(hash) {
  var number = hash.table_id;
  var players = hash.players;
  var count = 0;
  var html = "<div class='poker_table'>"+
            "<h3>"+
              "<div class='pull_left'>Table " + number + "</div>"+
              "<div class='clearfix'></div>" +
            "</h3>" +
            "<table class='players'>";
  for(var i in players) {
    var player = players[i];
    count += 1;
    if(count <= 3) {
      html += "<td class='bottom'>" +
                "<span class='name'>" + player.name + "</span>" +
                "<span class='stack'>" + player.stack + "</span>" +
                "<span class='hand'>" + player.hand + "</span>" +
              "</td>";
    } else {
      html += "<td>"
                "<span class='hand'>" + player.hand + "</span>" +
                "<span class='stack'>" + player.stack + "</span>" +
                "<span class='name'>" + player.name + "</span>" +
              "</td>"
    }
  }
  html += "</tr></table>"
  html += "<div class='clearfix' style='margin-bottom:10px;'>"
  html += "<div class='last_winner'>"
  $.each(hash.latest_winners, function() {
    var winner = $(this)[0];
    html += "<span>" + winner.name + " won " + winner.winnings + "</span>";    
  });
  return html;
}
function getURLParameter(name) {
  return decodeURI(
    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
  );
}
