/*
 * Script.js
 * Author: Ideaware Co
 *
 * Copyright 2013, Jacob Kelley - http://jakiestfu.com/
 * Released under the MIT Licence
 */


$(document).ready(function(){

  var editor = new wysihtml5.Editor("contest_description", { // id of textarea element
    toolbar:      "wysihtml5-toolbar-1", // id of toolbar element
    stylesheets:  "",
    parserRules:  wysihtml5ParserRules // defined in parser rules set
  });

  var editor2 = new wysihtml5.Editor("contest_additional_details", { // id of textarea element
    toolbar:      "wysihtml5-toolbar-2", // id of toolbar element
    stylesheets:  "",
    parserRules:  wysihtml5ParserRules // defined in parser rules set
  });

  var editor3 = new wysihtml5.Editor("contest_judging_criteria", { // id of textarea element
    toolbar:      "wysihtml5-toolbar-3", // id of toolbar element
    stylesheets:  "",
    parserRules:  wysihtml5ParserRules // defined in parser rules set
  });

});

// Resize Thumb Contest Home

// Layout Admin Site
$(".content-side").width($(window).width()-355);

// Format Currency Donation
$(".makereward").autoNumeric('init');


// Windows Resize
$(window).resize(function () {
    $(".content-side").width($(window).width()-355);
});

// Active/Delete Users Admin
$("body").on("click",".delete", function(event) {
  $(this).parents( ".list-thumb" ).remove();
});
// Pause Contest
$("body").on("click",".pause", function(event){
  $(this).parents(".actions-users").siblings(".pause-state").removeClass("hide");
  $(this).parents(".actions-users").siblings(".pause-state").addClass("showing");
  $(this).parents(".actions-users").addClass("hide");
});
// Resume Paused Contest
$("body").on("click",".resume", function(event){
  $(this).parents(".pause-state").removeClass("show");
  $(this).parents(".pause-state").addClass("hide");
  $(this).parents(".list-thumb").find(".actions-users").removeClass("hide");
});

$('.selectpicker').selectpicker();

function today(){
    var d = new Date();
    var curr_date = d.getDate();
    var curr_month = d.getMonth() + 1;
    var curr_year = d.getFullYear();
    document.write(curr_date + "-" + curr_month + "-" + curr_year);
}

$(".enddate").datepicker({
  format: "mm-dd-yyyy",
  startDate: "today",
  autoclose: true,
  weekStart: 1
});

$(".startdate").datepicker({
  format: "mm-dd-yyyy",
  startDate: "today",
  autoclose: true,
  weekStart: 1
});

$(".input-group .date").datepicker({
  format: "mm-dd-yyyy",
  startDate: "today",
  startView: "decade",
  autoclose: true,
  weekStart: 1
});

// Nested Fields Stuff (School Info Form)
// Add loan number on every new field
$(document).on('nested:fieldAdded', function(event){
  // this field was just inserted into your form
  var field = event.field;
  var count = field.parents('.edit_user').find('.loan-number').length;
  field.find('.loan-number').each(function(){
    $(this).text($(this).text() + " #" + count);
  });

  var loanAmount = field.find('.loan-amount');
  loanAmount.autoNumeric('init');
});

if($('.edit_user')){
  var loans = $('.edit_user').find(".loan-number");
  if (loans){
    var i = 1;
    loans.each(function(){
      $(this).text($(this).text() + " #" + i);
      i += 1;
    });
  }
  $('.loan-amount').autoNumeric('init');
}

// Login Required Layer
$(".logrequired").click(function(){
  $(".layersign").slideDown();
  setTimeout(function() {
    $(".layersign").slideUp();
  }, 4000);
});
$(".layersign a.close").click(function(){
  $(".layersign").slideUp();
});

if ($(".flash-open").length > 0){
  $(".layersign").slideDown();
  setTimeout(function() {
    $(".layersign").slideUp();
  }, 4000);
}

// Blur Effect for Cover Photo Contest
if ($(".intro-contest").length > 0){
  var vague = $('.header-contest-show .bg').Vague({
        intensity:      5,      // Blur Intensity
        forceSVGUrl:    false,   // Force absolute path to the SVG filter,
        // default animation options
        animationOptions: {
          duration: 1000,
          easing: 'linear' // here you can use also custom jQuery easing functions
        }
    });
    vague.blur();
}

//CONTESTS TYPE
$("#contest_category_contests_attributes_0_category_id_4").change(function() {
    if(this.checked) {
      $("#caption-image-field").show();
    }
    else{
      $("#caption-image-field").hide();
    }
});

$("#contest_category_contests_attributes_0_category_id_1").change(function() {
    var check_box =  $('#contest_multiple_images');
    var label = $('label[for="contest_multiple_images"]');
    if(this.checked) {
      check_box.removeClass("hide")
      check_box.show();
      label.removeClass("hide");
      label.show();
    }
    else{
      check_box.hide();
      label.hide();
    }
});

$("#contest_category_contests_attributes_0_category_id_5").change(function() {
    var check_box =  $('#contest_show_image');
    var label = $('label[for="contest_show_image"]');
    var check_box2 =  $('#contest_show_image_on_entry');
    var label2 = $('label[for="contest_show_image_on_entry"]');

    if(this.checked) {
      check_box.removeClass("hide")
      check_box.show();
      label.removeClass("hide");
      label.show();
      check_box2.removeClass("hide")
      check_box2.show();
      label2.removeClass("hide");
      label2.show();
    }
    else{
      check_box.hide();
      label.hide();
      check_box2.hide();
      label2.hide();
    }
});


$('div.content-side ul.pagination a').attr('data-remote', 'true');
$("div.content-side ul.pagination a:not([href])").removeAttr('data-remote');

$('div.content-side').on("keyup", "#search", function(){
  $.get($("div.search form").attr("action") + ".js", $("div.search form").serialize());
  return false;
});

$(document).ajaxComplete(function(){
  $('div.content-side ul.pagination a').attr('data-remote', 'true');
  $("div.content-side ul.pagination a:not([href])").removeAttr('data-remote');
});


// Filter for contest status

$("#admin-filter-dropdown.selectpicker").on("change", function(){
  var option = $(this).find("option:selected");
  var object = $(".all-free-premium.active");
  var object2 = $("#admin-sort-filter-dropdown.selectpicker").find("option:selected");
  var url = "/admin/contests.js?"+option.data("url")+ '&' + object2.data('url')+ '&' + object.data('url');
  console.log(url);
  $.ajax({
    url: url,
    type: "GET"
  });
   $(".icnloading_ajax").toggle();
});

// Filter for contests type

$("#admin-sort-filter-dropdown.selectpicker").on("change", function(){
  var option = $(this).find("option:selected");
  var object = $("#admin-filter-dropdown.selectpicker").find("option:selected");
  var object2 = $(".all-free-premium.active");
  var url = '/admin/contests.js?' + option.data("url") + '&' + object.data('url') + '&' + object2.data('url');
  console.log(url);
  $.ajax({
    url: url,
    type: "GET"
  });
   $(".icnloading_ajax").toggle();
});

/* Filter */

$( ".filter-menu-right .btn-list li a" ).click(function() {
  $( ".filter-menu-right .btn-list li").removeClass('active');
  $(this).parent().addClass('active');
});

$('.btn-list').click( function(){
  var object = $(".all-free-premium.active");
  var object2 = $("#admin-filter-dropdown.selectpicker").find("option:selected");
  var option = $("#admin-sort-filter-dropdown.selectpicker").find("option:selected");
  var url = '/admin/contests.js?' + object.data('url') + '&' + object2.data('url') + '&' + option.data("url");
  console.log(url);
  $.ajax({
    url: url,
    type: "GET"
  });
  $(".icnloading_ajax").toggle();
});
