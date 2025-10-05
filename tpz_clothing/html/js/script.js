
function CloseNUI() {

  $("#main").fadeOut();
  $(".clothing-section").hide();
  $(".clothing-buy-section").hide();
  $(".clothing-selected-section").hide();
  $("#categories-list").html('');

  $("#clothing-info-text").show();
  $("#clothing-buy-button").show();
  $("#clothing-save-button").show();
  $("#clothing-close-button").show();

  $.post('http://tpz_clothing/close', JSON.stringify({}));
}

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

		if (item.type == "enable") {
			document.body.style.display = item.enable ? "block" : "none";

      $(".clothing-section").show();

      if (item.enable) {
        $("#main").fadeIn(1000);
      }

    } else if (item.action == "set_management_section") {

      item.enable ? $(".management-section").fadeIn() : $(".management-section").fadeOut();

    } else if (item.action == "reset_categories") {
      
      $("#categories-list").html('');

    } else if (item.action == "display_categories") {

      $(".clothing-buy-section").show();
    
      $("#clothing-info-text").hide();
      $("#clothing-buy-button").hide();
      $("#clothing-save-button").hide();
      $("#clothing-close-button").hide();

    } else if (item.action == "set_information") {

      $("#clothing-title").text(item.title);
      $("#clothing-close-button").text(item.locales['NUI_CLOSE']);
      $("#clothing-save-button").text(item.locales['NUI_SAVE_OUTFIT']);
      $("#clothing-buy-button").text(item.locales['NUI_BUY_OUTFITS']);
      $("#clothing-buy-back-button").text(item.locales['NUI_BACK_OUTFITS']);
      $("#clothing-selected-back-button").text(item.locales['NUI_BACK_OUTFITS']);
      $("#clothing-selected-reset-button").text(item.locales['NUI_RESET_OUTFIT_TYPE']);

      $("#clothing-selected-select-tint-button").text(item.locales['NUI_SELECT_TINT']);
      $("#clothing-selected-component-title").text(item.locales['NUI_SELECT_COMPONENT']);
      $("#clothing-selected-palette-title").text(item.locales['NUI_SELECT_PALETTE_TITLE']);


      document.getElementById('clothing-info-text').innerHTML = item.locales['NUI_MAIN_PAGE_DESCRIPTION'];

    } else if (item.action == "insertCategory") {

      let res = item.result;

      $("#categories-list").append(
        `<div id="categories-list-name" title = "` + res.label + `" category = "` + res.category + `" >` + res.label + `</div>` +
        `<div> &nbsp; </div>`
      );

    } else if (item.action == 'selectedCategory') {

      let res = item.result;
      let max = Number(res.max);

      CURRENT_CLOTHING_CATEGORY_ITEM = res.current;
      MAXIMUM_CLOTHING_CATEGORY_ITEMS = max;

      $("#currentNumber").text(res.current + ' / ' + max);

      $("#clothing-selected-title").text(res.title);

    } else if (item.action == 'setOutfitComponentInformation') {

      if (item.texture_id != null ){
        $("#currentNumber").text(item.texture_id + ' / ' + item.max_textures);
      }
      
      $("#palette-currentNumber").text(item.current + ' / ' + item.max);

      SELECTED_ITEM_PALETTE_ID = item.current;
      SELECTED_ITEM_MAXIMUM_PALETTES = item.max;

      $('.r-num, .r-range').val(item.tint0);
      $('.g-num, .g-range').val(item.tint1);
      $('.b-num, .b-range').val(item.tint2);

      let bought = item.bought == 1 ? item.bought_locale : item.buy_locale;

      if (item.bought == -1) {
        bought = item.not_for_sell_locale;
      }
      
      $("#clothing-selected-buy-button").text(bought);

      if (item.bought == 1 ){
        $("#clothing-selected-buy-button").css("text-decoration", "line-through");
        $("#clothing-selected-buy-button").css("color", "rgba(117, 117, 117, 1)");

      }else if (item.bought == -1){
        $("#clothing-selected-buy-button").css("text-decoration", "line-through");
        $("#clothing-selected-buy-button").css("color", "rgb(173, 33, 33)");

      }else{
        $("#clothing-selected-buy-button").css("text-decoration", "none");
        $("#clothing-selected-buy-button").css("color", "rgb(192, 170, 47)");
      }

      $("#clothing-selected-buy-text").text(item.cost_locale);

    } else if (item.action == 'setOutfitComponentAsPurchased') {

      $("#clothing-selected-buy-button").text(item.bought_locale);
      $("#clothing-selected-buy-button").css("text-decoration", "line-through");
      $("#clothing-selected-buy-button").css("color", "rgba(117, 117, 117, 1)");

    } else if (item.action == "close") {
      CloseNUI();
    }

    (function () {
      const rNum = document.querySelector('.r-num');
      const gNum = document.querySelector('.g-num');
      const bNum = document.querySelector('.b-num');
      const rRange = document.querySelector('.r-range');
      const gRange = document.querySelector('.g-range');
      const bRange = document.querySelector('.b-range');

      function updatePreview() {
        const r = parseInt(rNum.value) || 0;
        const g = parseInt(gNum.value) || 0;
        const b = parseInt(bNum.value) || 0;
        rRange.value = r; gRange.value = g; bRange.value = b;

        SELECTED_ITEM_TINT1 = r;
        SELECTED_ITEM_TINT2 = g;
        SELECTED_ITEM_TINT3 = b;
      }

      [rNum, gNum, bNum].forEach(el => {
        el.addEventListener('input', updatePreview);
      });

      rRange.addEventListener('input', () => { rNum.value = rRange.value; updatePreview(); });
      gRange.addEventListener('input', () => { gNum.value = gRange.value; updatePreview(); });
      bRange.addEventListener('input', () => { bNum.value = bRange.value; updatePreview(); });


      updatePreview();
    })();
  });

  function ResetColorPalette(){
    const rNum = document.querySelector('.r-num');
    const gNum = document.querySelector('.g-num');
    const bNum = document.querySelector('.b-num');
    const rRange = document.querySelector('.r-range');
    const gRange = document.querySelector('.g-range');
    const bRange = document.querySelector('.b-range');

    const r = 0;
    const g = 0;
    const b = 0;
    rRange.value = r; gRange.value = g; bRange.value = b;

    rNum.value = 0;
    gNum.value = 0;
    bNum.value = 0;

    SELECTED_ITEM_TINT1 = 0;
    SELECTED_ITEM_TINT2 = 0;
    SELECTED_ITEM_TINT3 = 0;
  }


  /* ------------------------------------------------
  ------------------------------------------------ */ 

  $("#main").on("click", "#clothing-close-button", function () {
    PlayButtonClickSound();
    CloseNUI();
  });


  $("#main").on("click", "#clothing-save-button", function () {
    PlayButtonClickSound();
    
    $.post('http://tpz_clothing/save', JSON.stringify({}));
  });

  $("#main").on("click", "#clothing-buy-button", function () {
    PlayButtonClickSound();
    $.post('http://tpz_clothing/request_clothing_categories', JSON.stringify({}));
  });

  $("#main").on("click", "#clothing-buy-back-button", function () {
    PlayButtonClickSound();

    $(".clothing-section").show();
    $(".clothing-buy-section").hide();

    $("#clothing-info-text").show();
    $("#clothing-buy-button").show();
    $("#clothing-save-button").show();
    $("#clothing-close-button").show();
  });

  $("#main").on("click", "#categories-list-name", function () {
    PlayButtonClickSound();

    let $button   = $(this);
    let $category = $button.attr('category');
    let $title    = $button.attr('title');

    $.post("http://tpz_clothing/request_category_data", JSON.stringify({ category: $category, title: $title }));

    $(".clothing-buy-section").hide();
    $(".clothing-selected-section").show();

  });


  $("#main").on("click", "#clothing-selected-back-button", function () {
    PlayButtonClickSound();

    $(".clothing-selected-section").hide();
    $(".clothing-buy-section").show();

    $.post("http://tpz_clothing/back", JSON.stringify({ 
      id: CURRENT_CLOTHING_CATEGORY_ITEM, 
      palette: SELECTED_ITEM_PALETTE_ID 
    }));
  });

  /* ------------------------------------------------
  ------------------------------------------------ */ 

  $("#main").on("click", "#prev", function () {
    PlayButtonClickSound();

    CURRENT_CLOTHING_CATEGORY_ITEM--;

    if (CURRENT_CLOTHING_CATEGORY_ITEM < 0) {
      CURRENT_CLOTHING_CATEGORY_ITEM = MAXIMUM_CLOTHING_CATEGORY_ITEMS;
    }

    SELECTED_ITEM_PALETTE_ID = 1;

    $("#currentNumber").text(CURRENT_CLOTHING_CATEGORY_ITEM + " / " + MAXIMUM_CLOTHING_CATEGORY_ITEMS);

    $.post("http://tpz_clothing/load_selected_cloth", JSON.stringify({
      id: CURRENT_CLOTHING_CATEGORY_ITEM,
      palette: 1,
      tint0: 0,
      tint1: 0,
      tint2: 0,
      actionType: 'COMPONENT',
    }));

  });

  $("#main").on("click", "#next", function () {
    PlayButtonClickSound();

    CURRENT_CLOTHING_CATEGORY_ITEM++;

    if (CURRENT_CLOTHING_CATEGORY_ITEM > MAXIMUM_CLOTHING_CATEGORY_ITEMS) {
      CURRENT_CLOTHING_CATEGORY_ITEM = 0;
    }

    SELECTED_ITEM_PALETTE_ID = 1;

    $("#currentNumber").text(CURRENT_CLOTHING_CATEGORY_ITEM + " / " + MAXIMUM_CLOTHING_CATEGORY_ITEMS);

    $.post("http://tpz_clothing/load_selected_cloth", JSON.stringify({
      id: CURRENT_CLOTHING_CATEGORY_ITEM,
      palette: 1,
      tint0: 0,
      tint1: 0,
      tint2: 0,
      actionType: 'COMPONENT',
    }));
  });

  $("#main").on("click", "#palette-prev", function () {
    PlayButtonClickSound();

    SELECTED_ITEM_PALETTE_ID--;

    if (SELECTED_ITEM_PALETTE_ID < 1) {
      SELECTED_ITEM_PALETTE_ID = SELECTED_ITEM_MAXIMUM_PALETTES;
    }

    $("#palette-currentNumber").text(SELECTED_ITEM_PALETTE_ID + " / " + SELECTED_ITEM_MAXIMUM_PALETTES);

    $.post("http://tpz_clothing/load_selected_cloth", JSON.stringify({
      id: CURRENT_CLOTHING_CATEGORY_ITEM,
      palette: SELECTED_ITEM_PALETTE_ID,
      tint0: 0,
      tint1: 0,
      tint2: 0,
      actionType: 'PALETTE',
    }));

  });

  $("#main").on("click", "#palette-next", function () {
    PlayButtonClickSound();

    SELECTED_ITEM_PALETTE_ID++;

    if (SELECTED_ITEM_PALETTE_ID > SELECTED_ITEM_MAXIMUM_PALETTES) {
      SELECTED_ITEM_PALETTE_ID = 1;
    }

    $("#palette-currentNumber").text(SELECTED_ITEM_PALETTE_ID + " / " + SELECTED_ITEM_MAXIMUM_PALETTES);

    $.post("http://tpz_clothing/load_selected_cloth", JSON.stringify({
      id: CURRENT_CLOTHING_CATEGORY_ITEM,
      palette: SELECTED_ITEM_PALETTE_ID,
      tint0: 0,
      tint1: 0,
      tint2: 0,
      actionType: 'PALETTE',
    }));
  });

  $("#main").on("click", "#clothing-selected-select-tint-button", function () {
    PlayButtonClickSound();

    $.post("http://tpz_clothing/load_selected_cloth", JSON.stringify({
      id: CURRENT_CLOTHING_CATEGORY_ITEM,
      palette: SELECTED_ITEM_PALETTE_ID,
      tint0: SELECTED_ITEM_TINT1,
      tint1: SELECTED_ITEM_TINT2,
      tint2: SELECTED_ITEM_TINT3,
      actionType: 'TINT',
    }));

  });

  $("#main").on("click", "#clothing-selected-reset-button", function () {
    PlayButtonClickSound();

    $.post("http://tpz_clothing/reset_outfit_category", JSON.stringify({
      actionType: 'RESET',
    }));

  });

  $("#main").on("click", "#clothing-selected-buy-button", function () {
    PlayButtonClickSound();
    $.post("http://tpz_clothing/buy_item", JSON.stringify({ id: CURRENT_CLOTHING_CATEGORY_ITEM, palette: SELECTED_ITEM_PALETTE_ID }));
  });

});
