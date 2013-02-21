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
      e = e.sort(function(a,b){return a-b});
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
      $('tbody.score').html("");
      $.each(e, function() {
        $('tbody.score').append(scoreboard($(this)[0]))
      }); 
    }
  });
}
function scoreboard(hash) {
  var player = hash.name;
  var stack = hash.stack;
  var lost = (hash.lost_at == null ? "" : " class='lost' " );
  html = "<tr"+lost+">" + 
            "<td>" + player + "</td>" +
            "<td class='chips'>" + stack + "</td>" +
          "</tr>";
  return html; 
}
function table(hash) {
  var number = hash.table_id;
  var players = hash.players;
  var c = 0;
  var html = "<div class='poker_table'>"+
            "<h3>"+
              "<div class='pull_left'>Table " + number + "</div>"+
              "<div class='clearfix'></div>" +
            "</h3>" +
            "<table class='players'>";
  for(var i=0; i<6; i++) {
    var name = "<span class='name lost'>empty seat</span>";
    var stack = "<span class='stack lost'>0</span>";
    if(i < superlength(players)) {
      name = "<span class='name'>" + players[i].name + "</span>";
      stack = "<span class='stack'>" + players[i].stack + "</span>";
    }
    c += 1;
    if(c <= 3) {
      html += "<td>" + name + stack + "</td>";
    }
    if(c == 3) {
      html += "</tr><tr><td class='pot_middle' colspan='3'>" +
                hash.pot + " in the pot</td></tr><tr>";
    }
    if(c > 3) {
      html += "<td class='bottom'>" + stack + name + "</td>";
    }
  }
  html += "</tr></table>"
  html += "<div class='clearfix'>"
  html += "<div class='last_winner'>"
  $.each(hash.latest_winners, function() {
    var winner = $(this)[0];
    html += "<span>" + winner.name + " won " + winner.winnings + "</span>";    
  });
  html += "<div class='clearfix'></div>"
  return html;
}
function getURLParameter(name) {
  return decodeURI(
    (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
  );
}
function superlength(obj) {
  var result = 0;
  for(var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
    // or Object.prototype.hasOwnProperty.call(obj, prop)
      result++;
    }
  }
  return result;
}

