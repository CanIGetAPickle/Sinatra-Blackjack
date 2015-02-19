$(document).ready(function(){
  player_hit();
  player_stay();
  dealer_hit();
});

function player_hit() {
  $(document).on("click", "form#hit_form input", function() {
    alert("You go for the hit!");
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);  //replaces HTML of entire game div with new contents that are returned
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "form#stay_form input", function() {
    alert("You chose to stay!");
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function dealer_hit() {
  $(document).on("click", "form#dealer_hit input", function() {
    alert("The dealer hits!");
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}
