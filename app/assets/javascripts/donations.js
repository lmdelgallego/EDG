$(document).ready(function(){
  if ($('meta[name="stripe-key"]').length > 0){
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
  }
  
  $("#new_donation").submit(function() {
    if (!($("#new_donation input[type=submit]").hasClass('logrequired'))){
      $(".overlay").removeClass("hide");
    }
    $(".step3").addClass("hide");
    $('input[type=submit]').attr('disabled', true);
    var form = $("#new_donation");
    
    if ($('#card_number').length){
      var card = {
        number:   $("#card_number").val(),
        expMonth: parseInt($("#card_month").val()),
        expYear:  parseInt($("#card_year").val()),
        cvc:      $("#card_code").val(),
        name:     $("#card_name").val()
      };      
      
      Stripe.createToken(card, function(status, response) {
        if (status === 200) {
          $("#donation_stripe_token").val(response.id);
          $("#card_number, #card_month, #card_year, #card_code, #card_name").attr('disabled', true);
          var target = form.attr('action');
          var form_data = form.serialize();
          $.ajax({
             url: target,
             data: form_data,
             type: "POST"
          });
        } else {
          $('input[type=submit]').attr('disabled', false);
          $(".step1").addClass("hide");
          $(".step3 p").html(response.error.message);
          $(".step3").removeClass("hide");
        }
      });
    
      return false;
    } 
    
  });
});
