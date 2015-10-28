/*
 * Script.js
 * Author: Ideaware Co
 *
 * Copyright 2014
 * Released under the MIT Licence
 */

 /* Character Limits */


// Menu Mobile

$( ".menu-mobile" ).click(function() {
  $( ".menu-mobile-list" ).slideToggle( "slow" );
});

/* Show-Hide Rules and Submit Form */

$( ".show-rules a" ).click(function() {
  $( ".content-rules" ).slideToggle( "slow" );
  $( ".show-rules" ).slideToggle( "hide" );
});

$( ".hide-rules" ).click(function() {
  $( ".content-rules" ).slideToggle( "slow" );
  $( ".show-rules" ).slideToggle( "show" );
});

$( ".form-submit a.showentry").click(function() {
  $( ".content-form").slideToggle( "slow" );
  $( ".form-submit").slideToggle( "hide" );
});

$( "a.hide-form" ).click(function() {
  $( ".content-form" ).slideToggle( "slow" );
  $( ".form-submit").slideToggle( "show" );
});


/* Flex Slider */
// Can also be used with $(document).ready()
$(window).load(function() {
  $('.flexslider').flexslider({
    animation: "slide"
  });
/* General Selects */
$(".data-zone.complete-info .bootstrap-select ul").find('li:first-child').css('display','none');


});


/*============================*/

/* Filter */

$( ".filter-menu-right .btn-list li a" ).click(function() {
  $( ".filter-menu-right .btn-list li").removeClass('active');
  $(this).parent().addClass('active');
   $(".contest-list").empty();
  $(".icnloading_ajax").toggle();
}); 

$( ".filter-menu-left div" ).click(function() {
   $(".contest-list").empty();
  $(".icnloading_ajax").toggle();
});  

/* Mobile */

$( ".menu-mobile-list .btn-list li a" ).click(function() {
  $( ".menu-mobile-list .btn-list li").removeClass('active');
  $(this).parent().addClass('active');
  $(".icnloading_ajax").toggle();
});  

// Snap JS
function snapMobile(){
    if ( screen.width <= 960 ){
        var snapper = new Snap({
            element: document.getElementById('webContent')
        });

        snapper.settings({disable:'right'});


        $('#open-left').click( function(){
            snapper.open('left');
        });

        $(".snapnav nav a:first-child").click( function(){
            snapper.close();
        });

    } else {
        var snapper = new Snap({
            element: document.getElementById('webContent'),
            touchToDrag: false
        });

        snapper.settings({disable:'right'});

        $('#open-left').click( function(){
            snapper.open('left');
        });

        $(".snapnav nav a:first-child").click( function(){
            snapper.close();
        });
    }
}

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
  $('.selectpicker').selectpicker();

  $(".onyl-year-month .date").datepicker({
    format: "mm-yyyy",
    startView: 2,
    minViewMode: 1,
    autoclose: true
  });

});

// Add loan number for the loans already created
$(document).ready(function(){

  $("#jquery_jplayer").jPlayer({
    ready: function () {
          $(this).jPlayer("setMedia", {
              title: "Audio Entry",
              //mp3: "http://www.jplayer.org/audio/mp3/TSP-01-Cro_magnon_man.mp3",
              mp3: $(".player-audio").data("url")
          });
    },
    swfPath: "../../dist/jplayer",
    cssSelectorAncestor: "#jp_container",
    supplied: "mp3",
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

  $('.selectpicker').selectpicker();

  $(".input-group .date").datepicker({
    format: "yyyy/mm/dd",
    startView: "decade",
    autoclose: true
  });

  $(".onyl-year-month .date").datepicker({
    format: "mm-yyyy",
    startView: 2,
    minViewMode: 1,
    autoclose: true
  });

  //Select Picker
  $(".year").datepicker({
    format: " yyyy",
    viewMode: "years",
    minViewMode: "years",
    autoclose: true
  });

  $(".month").datepicker({
    format: " mm",
    viewMode: "months",
    minViewMode: "months",
    autoclose: true
  });

  $('a.load-more-items').on('inview', function(e, visible) {
    if (!visible) {
      return;
    }
    var target = $(this).attr('href');
    if (target != "#"){
      target= target.split("amp;").join("");
      $.getScript(target);
    }
  });

  $("time.timeago").timeago();

  // Format Currency Donation
  $(".makedonation").autoNumeric('init');


  // Script Entry Type
  if ($(".modal-body").find(".image-container").length > 0) {
    $(".votes-share").css("float","left");
  } else {
    $(".votes-share").css("width","100%");
  }


  //Closing Modal
  $('body').on("click",".modal-backdrop", function(event){
    $('#readrules, #submitentry, #detailcontest').modal('hide');
    $("#entryform").empty();
  });
  
  if ($(".noti").length > 0){
    var notis_count = $(".drop-notifications a").length;
    if (notis_count > 0){
      $(".notification span.counter").html(notis_count);
      $(".notification span.counter").show();
    }
  }

  // Closing Modal and Clearing entry form with ESC Key
  $(document).keyup(function(e) {
    if (e.keyCode == 27) { // esc
      $('#readrules, #submitentry, #detailcontest').modal('hide');
      $("#entryform").empty(); 
    }
  });
  
  // iPad Touch
  if(navigator.userAgent.match(/iPad/i)) {
    $(".over").click(function(){
      $(".over").removeClass("show");
      $(".drop-notifications").removeClass("visible");
      $(".dropoptions").removeClass("visible");
    });
  }

  $("body").on("click", ".filter-menu ul a", function(){
    $(".contest-list").empty();
    $(".entries-container").empty();
    $(".icnloading_ajax").toggle();
  });

  // Character Counter
  var text_max = $('textarea.entrytextarea, .countcharacter textarea').attr('maxLength');
  $('#textarea_feedback').html(text_max + ' Characters Maximum');

  $('body').on('keyup','.countcharacter textarea', function() {
      var text_length = $('.countcharacter textarea').val().length;
      var text_remaining = text_max - text_length;
      // Inner Counter in HTML
      $('#textarea_feedback').html(text_remaining + ' Characters Remaining');
  });

  $('body').on('keyup','textarea.entrytextarea', function() {
      var text_length = $('textarea.entrytextarea').val().length;
      var text_remaining = text_max - text_length;
      // Inner Counter in HTML
      $('#textarea_feedback').html(text_remaining + ' Characters Remaining');
  });


     /*  File Upload */

    var progressbox     = $('#progressbox');
    var progressbar     = $('#progressbar');
    var statustxt       = $('#statustxt');
    var completed       = '0%'; 

    var options = { 
        target:   '#output', 
        beforeSubmit:  beforeSubmit,
        uploadProgress: OnProgress, //upload progress callback 
        success:       afterSuccess,
        resetForm: true  
    }; 
        
     $('#MyUploadForm').submit(function() { 
        $(this).ajaxSubmit(options);            
        return false; 
     });

  /* End Upload */   

      function OnProgress(event, position, total, percentComplete){
          //Progress bar
          progressbar.width(percentComplete + '%') //update progressbar percent complete
          statustxt.html(percentComplete + '%'); //update status text
          if(percentComplete > 50) { 
                statustxt.css('color','#fff'); //change status text to white after 50% 
          }
      } 

      function afterSuccess(){
        $('#submit-btn').show(); //hide submit button
        $('#loading-img').hide(); //hide submit button
      }

      function beforeSubmit(){
        //check whether browser fully supports all File API
       if (window.File && window.FileReader && window.FileList && window.Blob)
      {

        if( !$('#imageInput').val()) //check empty input filed
        {
          $("#output").html("Are you kidding me?");
          return false
        }
        
        var fsize = $('#imageInput')[0].files[0].size; //get file size
        var ftype = $('#imageInput')[0].files[0].type; // get file type
        
        //allow only valid image file types 
        switch(ftype)
            {
                case 'image/png': case 'image/gif': case 'image/jpeg': case 'image/pjpeg':
                    break;
                default:
                    $("#output").html("<b>"+ftype+"</b> Unsupported file type!");
            return false
            }
        
        //Allowed file size is less than 1 MB (1048576)
        if(fsize>1048576) 
        {
          $("#output").html("<b>"+bytesToSize(fsize) +"</b> Too big Image file! <br />Please reduce the size of your photo using an image editor.");
          return false
        }
        
        //Progress bar
        progressbox.show(); //show progressbar
        progressbar.width(completed); //initial value 0% of progressbar
        statustxt.html(completed); //set status text
        statustxt.css('color','#000'); //initial color of status text

            
        $('#submit-btn').hide(); //hide submit button
        $('#loading-img').show(); //hide submit button
        $("#output").html("");  
      }
      else
      {
        //Output error to older unsupported browsers that doesn't support HTML5 File API
        $("#output").html("Please upgrade your browser, because your current browser lacks some new features we need!");
        return false;
      }
    }

    //function to format bites bit.ly/19yoIPO
    function bytesToSize(bytes) {
       var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
       if (bytes == 0) return '0 Bytes';
       var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
       return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    }

    /*Image Slider*/
    $('.entry-image-slide').flexslider({
      animation: "slide",
      animationLoop: false
    });

    /*match height boxes*/
    jQuery('.students .members').matchHeight();

    jQuery('.entry-image-slide ul.slides li').matchHeight();

    jQuery( window ).resize(function() {
      jQuery('.entry-image-slide ul.slides li').matchHeight();
    });

  // Script for home carousel
  var numOfItem = $('#carousel-home').find('.carousel-inner .item');
  $('#carousel-home .carousel-indicators li').css({
    width: 'calc(100%/'+numOfItem.length+' - 6px)'
  });

  var sideBar = $('#filterList') 
  var offset = sideBar.offset();
  var topPadding = 15;
  $(window).scroll(function(event) {
    if (sideBar.height() < $(window).height() && $(window).scrollTop() > offset.top ) {
      sideBar.stop().animate({marginTop: $(window).scrollTop() - offset.top + topPadding}, 300)
    }else{
      sideBar.stop().animate({marginTop: 0})
    };
  });

  // Script for countdown
  var timer = $("#timer");
  timer.countdown(timer.data('finaldate'), function(event) {
   //timer.text(event.strftime('%D days %H:%M:%S'));
   var days = $('#days .number');
   var hrs = $('#hrs .number');
   var min = $('#min .number');
   var seg = $('#seg .number');
    if(event.offset.days > 0) {
      var days = $('#days .number');
      days.text(event.strftime('%D'));
      seg.parents('#seg').remove();
    }else{
      days.parents('#days').remove();
    }
    hrs.text(event.strftime('%H'));
    min.text(event.strftime('%M'));
    seg.text(event.strftime('%S'));
   });

});

// Dropdown User Top
$('body').on("click",".userdrop > div.name a",function(event){
  if ( $(".dropoptions").hasClass("visible") ) {
      $(".dropoptions").removeClass("visible");
      $(".over").removeClass("show");
  } else {
      $(".dropoptions").toggleClass("visible");
      $(".over").toggleClass("show");
      $(".drop-notifications").removeClass("visible");
      
  }
});
$('body').on("click",".over",function(event){
  $(".over").removeClass("show");
  $(".drop-notifications").removeClass("visible");
  $(".dropoptions").removeClass("visible");
});

// $(document).click(function(){
//     $(".dropoptions, .drop-notifications").removeClass("visible");
// });

$('body').on("click",".userdrop .noti a",function(event){
  if ( $(".drop-notifications").hasClass("visible") ) {
    $(".drop-notifications").removeClass("visible");
    $(".over").removeClass("show");
  } else {
    $(".over").toggleClass("show");
    $(".drop-notifications").toggleClass("visible");
    $(".dropoptions").removeClass("visible");
    $.ajax({
        type: "GET",
        url: "/users/read_my_notifications.json"
      })
      .always(function() {
        $(".notification span.counter").hide();
      });
  }
});

$(document).ajaxComplete(function(){
  if (document.querySelector('.post') != null){
    //doSomething(); //Masonry
  }

  $("time.timeago").timeago();

  if ($(".modal-body").find(".image-container, .player-audio").length > 0) {
    $(".votes-share").css("float","left");
  } else {
    $(".votes-share").css("width","100%");
  }


});


// Share Button Entries
$('body').on("click",".btn-share",function(event){
  event.stopPropagation();
  if(! $(this).siblings(".share-options").hasClass("show")){
    $("#entry-detail").css("overflow","inherit");
    $(".share-options").removeClass("show");
    $(this).siblings(".share-options").addClass("show");
    $(this).addClass("active");
  } else {
    $("#entry-detail").css("overflow","scroll");
    $(this).siblings(".share-options").removeClass("show");
    $(this).removeClass("active");
  }
});

$('body').on("click",".share-options",function(event){
  event.stopPropagation();
});

$(document).click(function(){
  $(".share-options").removeClass("show");
  $("#entry-detail").css("overflow","scroll");
  $(".share-cloud > div.btn-share").removeClass("active");
});

$('body').on("click",".share-options a",function(event){
  $(".share-options").removeClass("show");
  $("#entry-detail").css("overflow","scroll");
  $("div.btn-share").removeClass("active");
});


// Thank Messagge
$(".jsubmit").click(function(){
  $(".overlay").removeClass("hide");
  $('form#new_entry').trigger('submit.rails');
});

$(".overlay").click(function(){
  $(this).addClass("hide");
  $(".step3").addClass("hide");
  $(".step2").addClass("hide");
  $(".step1").removeClass("hide");
});

$("#new_entry").submit(function(){
  $('#modal-id').modal('hide');
  $("#entryform").empty();
  $(".overlay").removeClass("hide");
  return true;
});

//Login Required Layer
$('body').on("click", ".logrequired", function(){
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

$(".opensubmitentry").click(function(){
  mytarget = $(this).data("url");
  $.ajax({
      url: mytarget,
      cache: false
    })
    .done(function( html ) {
      $("#entryform").append( html );
    });
});

$( ".entries-container" ).on( "click", ".detailentry", function( event ) {
    mytarget = $(this).data("url");
    $.ajax({
        url: mytarget,
        cache: false
      });
});

$(".close").click(function(){
  $( "#entryform" ).empty();
  $("#entry-detail").empty();
});

$('body').on("click","#entryform .actions a.btn-bordergrey",function(event){
  $( "#entryform" ).empty();
  $("#entry-detail").empty();
});

// This event belongs to the old frontend
$("#sort-filter-dropdown.selectpicker").on("change", function(){
  $(".icnloading_ajax").toggle();
  var option = $(this).find("option:selected");
  var object3 = $(".all-free-premium.active");
  var object2 = $(".open-closed.green");
  var url = '/contests.js?' + option.data("url") + '&' + object3.data('url') + '&' + object2.data('url');
  $.ajax({
    url: url,
    type: "GET"
  });
  $(".icnloading_ajax").toggle();
});

// This event belongs to the new frontend
$(".change-category").on("click", function(){
  $(".icnloading_ajax").toggle();
  $(this).parents(".filterList").find("li").removeClass("active");
  $(this).addClass('active');
  var category = $(this).data("url");
  var order = $("#selectFilter").find("option:selected").data("url");
  var url = '/home.js?' + category + '&status=active&' + order;
  $.ajax({
    url: url,
    type: "GET"
  });
  $(".icnloading_ajax").toggle();
});

// List contest by date created
$("#selectFilter").on("change", function(){
  var order = $(this).find('option:selected').data("url");
  console.log(order)
  var category  = $(".change-category.active").data("url");
  var url = '/home.js?' + order + '&status=active&'+category;
  $.ajax({
    url: url,
    type: "GET"
  });

});

$("#sort-filter-open").click( function(){
  var object= $("#sort-filter-open")
  var object2= $("#sort-filter-closed")
  var object3 = $(".all-free-premium.active");
  object.removeClass("gray");
  object.addClass("green");
  object2.removeClass("green");
  object2.addClass("gray");
  var option = $("#sort-filter-dropdown").find("option:selected");
  var url = '/contests.js?' + object.data('url') + '&' + object3.data('url') + '&' +option.data("url");
  console.log(url);
  $.ajax({
    url: url,
    type: "GET"
  });
  $(".icnloading_ajax").fadeToggle('0');
});

$("#sort-filter-closed").click( function(){
  var object= $("#sort-filter-closed")
  var object2= $("#sort-filter-open")
  var object3 = $(".all-free-premium.active");
  object.removeClass("gray");
  object.addClass("green");
  object2.removeClass("green");
  object2.addClass("gray");
  var option = $("#sort-filter-dropdown").find("option:selected");
  var url = '/contests.js?' + object.data('url') + '&' + object3.data('url') + '&' +option.data("url");
  console.log(url);
  $.ajax({
    url: url,
    type: "GET"
  });
  $(".icnloading_ajax").fadeToggle('0');
});


$('.btn-list').click( function(){
  var object = $(".all-free-premium.active");
  var object2 = $(".open-closed.green");
  var option = $("#sort-filter-dropdown").find("option:selected");
  var url = '/contests.js?' + object.data('url') + '&' + object2.data('url') + '&' + option.data("url");
  $.ajax({
    url: url,
    type: "GET"
  });
  $(".icnloading_ajax").fadeToggle('0');
});

// Fire submit event on search form in header when search button is clicked
$("#search-contest-button").on("click", function(){
  $("#search-contest-form").submit();
});

/* Reset Form Entry */

// jQuery.fn.reset = function () {
//   $(this).each (function() { this.reset(); });
// }

$( "body" ).on("click",".closeformentry",function() {

  $( ".content-form" ).slideToggle( "slow" );
  $( ".form-submit").slideToggle( "show" );

  // $('.new_entry')[0].reset();
  if( $(".profile-edit-entry").length > 0 ){
    $( ".profile-edit-entry" ).slideToggle( "slow", function(){
      $(this).html('');
      $(this).slideToggle( "slow" );
    });
  }

});

/* File Upload  */

$('[data-countdown]').each(function() {
   var $this = $(this), finalDate = $(this).data('countdown');
   $this.countdown(finalDate, function(event) {
     $this.html(event.strftime('%D days %H hrs %M min %S sec'
      ));
   });
 });

// SHare cloud

$('#share-contest').on("click", function(){
  $(".share-cloud").toggleClass("hide");
});


