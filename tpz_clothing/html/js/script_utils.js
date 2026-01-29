let CURRENT_CLOTHING_CATEGORY_ITEM  = 1;
let MAXIMUM_CLOTHING_CATEGORY_ITEMS = 0;
let SELECTED_ITEM_TINT1             = 0;
let SELECTED_ITEM_TINT2             = 0;
let SELECTED_ITEM_TINT3             = 0;
let SELECTED_ITEM_PALETTE_ID        = 1;
let SELECTED_ITEM_MAXIMUM_PALETTES  = 1;

let HAS_COOLDOWN = false;

let IS_NUI_ACTIVE = false

document.addEventListener("DOMContentLoaded", function () {

  $("#main").fadeOut();

  displayPage("clothing-section", "visible");
  $(".clothing-section").fadeOut();

  displayPage("clothing-buy-section", "visible");
  $(".clothing-buy-section").fadeOut();

  displayPage("clothing-selected-section", "visible");
  $(".clothing-selected-section").fadeOut();

});

function PlayButtonClickSound() {
  var audio = new Audio('./audio/button_click.wav');
  audio.volume = 0.3;
  audio.play();
}

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function ResetCooldown(){ setTimeout(function () { HAS_COOLDOWN = false; }, 500); }
