//= require jquery
//= require bootstrap 

$(function() {
  reload_tables();
  reload_scoreboard();
  var refresh = getURLParameter("refresh");
  var delay = (getURLParameter("delay") == "pete" ? 1000 : 10000);
  setInterval(function() { reload_tables(); }, delay);
  //setInterval(function() { reload_scoreboard(); }, 5000);
})

function reload_tables() {
  $.ajax({
    url: '/tournaments/tables',
    type: 'GET',
    success: function(e) {
      $('#poker_tables').html("");
      e = e.sort(function(a,b){return a-b});
      if(superlength(e) == 1) {
        $('#poker_tables').addClass('big');
        $('#poker_tables').append(table(e[0], true));
      } else {
        $('#poker_tables').removeClass('big');
        $.each(e, function() {
          $('#poker_tables').append(table($(this)[0]))
        });
      }
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
  var player  = hash.name,
      stack   = hash.stack,
      lost    = (hash.lost_at == null ? "" : " class='lost' " );

  html = "<tr" + lost + ">" + 
            "<td>" + player + "</td>" +
            "<td class='chips'>" + stack + "</td>" +
          "</tr>";

  return html; 
}

function table(hash, big) {
  var number  = hash.table_id,
      players = hash.players,
      c       = 0;

  var html = 
    "<div class='poker_table'>" +
      "<table class='players'>";

  for(var i = 0; i < 8; i++) {
    var hands = "",
        name  = "",
        stack = "<span class='stack lost'></span>";

    if(i < superlength(players)) {
      hands = "<span class='cards'>" + players[i].hand + "</span>";
      name = "<span class='name'>" + players[i].name + "</span>";
      stack = "<span class='stack'>" + players[i].stack + "</span>";
    }

    c += 1;

    if(c <= 4) {
      html += "<td><div class='player'>" + name + stack + hands + "</div></td>";
    }

    if(c == 4) { 
      if(hash.community_cards == "") {
        hash.community_cards = '<div class="card blank"><div class="suit">#</div>#</div><div class="card blank"><div class="suit">#</div>#</div><div class="card blank"><div class="suit">#</div>#</div>'
      }
      html += 
        "<tr>" +
          "<td class='pot_middle' colspan='6'>" +
            "<span class='the_pot'>" + hash.pot + "</span>" +
            "<span class='community_cards'>" + hash.community_cards + "</span>" +
          "</td>" +
        "</tr>";
    }

    if(c > 4) {
      html += "<td class='bottom'><div class='player'>" + hands + stack + name + "</div></td>";
    }
  }

  html += "</tr></table>"

  html += "<div class='last_winner'>"
  $.each(hash.latest_winners, function() {
    var winner = $(this)[0];
    html += "<span>" + winner.name + " won $" + winner.winnings + "</span>";    
  });

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

