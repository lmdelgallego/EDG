$(document).ready(function(){
  $("#user_t_price").on('change', function(){
    var selected = $( "#user_t_price option:selected" )
    var suscriptionForm = $(this).parents("form");
    price = selected.data('price');
    aprice = selected.data('aprice');
    n_e = selected.data('entries');
    var message =""
    var payment_option = $( "#account-type option:selected").val();

    if (selected.val() == "2"){
      $(".many-entry-count").removeClass("hide");
      $(".many-entry-count").show();
      message = getMessage(payment_option,selected.val(), n_e, price,aprice)
      $(".payment-fields").removeClass("hidden");
      $("#subs_message").html(message);

        if(payment_option == "m"){
          suscriptionForm.find("input[type=submit]").val("PAY $" + price);
        }else{
          suscriptionForm.find("input[type=submit]").val("PAY $" + aprice);
        }
      
      suscriptionForm.addClass("pay-suscription");
      $('li.facebook a').attr("href", "/users/auth/facebook?donor=true")
      $('li.twitter a').attr("href", "/users/auth/twitter?donor=true")
      $('li.googlep a').attr("href", "/users/auth/google?donor=true")
      $('li.linkedin a').attr("href", "/users/auth/linkedin?donor=true")

    }else if (selected.val() == "1"){
      $(".many-entry-count").hide();
      message = getMessage(payment_option,selected.val(), n_e, price, aprice)
      $("#subs_message").html(message);
      $('li.facebook a').attr("href", "/users/auth/facebook")
      $('li.twitter a').attr("href", "/users/auth/twitter")
      $('li.googlep a').attr("href", "/users/auth/google")
      $('li.linkedin a').attr("href", "/users/auth/linkedin")
      $(".payment-fields").addClass("hidden");
      suscriptionForm.find("input[type=submit]").val("Sign me up");
      suscriptionForm.removeClass("pay-suscription");
    }
   
  });

  $("#account-type").on('change', function(){
    //var selected = $( "#user_t_price option:selected" )
    var selected ="2";
    var div = $('.many-entry-count');
    var suscriptionForm = $(this).parents("form");
    //price = selected.data('price');
    //aprice = selected.data('aprice');
    //n_e = selected.data('entries');
    price = div.data('price');
    aprice = div.data('aprice');
    n_e = div.data('entries');
    console.log(price);
    var payment_option = $( "#account-type option:selected").val();
    var message =""
    if (selected == "2"){
      message = getMessage(payment_option,selected, n_e, price,aprice)
      $(".payment-fields").removeClass("hidden");
      $("#subs_message").html(message);
      if(payment_option == "m"){
        suscriptionForm.find("input[type=submit]").val("PAY $" + price);
      }else{
        suscriptionForm.find("input[type=submit]").val("PAY $" + aprice);
      }
      suscriptionForm.addClass("pay-suscription");
      $('li.facebook a').attr("href", "/users/auth/facebook?donor=true")
      $('li.twitter a').attr("href", "/users/auth/twitter?donor=true")
      $('li.googlep a').attr("href", "/users/auth/google?donor=true")
      $('li.linkedin a').attr("href", "/users/auth/linkedin?donor=true")
    }else if (selected == "1"){
      message = getMessage(payment_option,selected, n_e, price, aprice)
      $("#subs_message").html(message);
      $('li.facebook a').attr("href", "/users/auth/facebook")
      $('li.twitter a').attr("href", "/users/auth/twitter")
      $('li.googlep a').attr("href", "/users/auth/google")
      $('li.linkedin a').attr("href", "/users/auth/linkedin")
      $(".payment-fields").addClass("hidden");
      suscriptionForm.find("input[type=submit]").val("Sign me up");
      suscriptionForm.removeClass("pay-suscription");
    }
   
  });
 



  $('body').on('submit','.pay-suscription',function(event){
    event.preventDefault();
    $(".overlay").removeClass("hide");
    if ($('meta[name="stripe-key"]').length > 0){
      Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
    }
    $(".step3").addClass("hide");
    var form = $("form.pay-suscription");
    var date = $("#card_month").val().split("/");

    if ($('#card_number').length){
      var card = {
        number:   $("#card_number").val(),
        expMonth: parseInt(date[0]),
        expYear:  parseInt(date[1]),
        cvc:      $("#card_code").val(),
        name:     $("#user_full_name").val()
      };      
      
      Stripe.createToken(card, function(status, response) {
        if (status === 200) {
          $("#user_stripe_token").val(response.id);
          $("#membership_stripe_token").val(response.id);
          form.removeClass("pay-suscription");
          form.submit();
        } else {
          console.log('error')
          $(".step1").addClass("hide");
          $(".step3 p").html(response.error.message);
          $(".step3").removeClass("hide");
        }
      });
    } 
    
    
    
    
    
  });
  
});

  function getMessage(option,payment, n_e, price, aprice){
    if(payment == "2"){
      if(option == "m"){
        return "You can submit unlimited entries and participate in exclusive premium contests for just  $"+ price + "/month.";
      }else{
        return "You can submit unlimited entries and participate in exclusive premium contests for just  $"+ aprice + "/year.";
      }
    }else{
      return "You can submit up to "+ n_e +" entries per month.";
    }
   
  }

 function isNumberKey(evt){
   var charCode = (evt.which) ? evt.which : event.keyCode
   if ((charCode > 47 && charCode < 58) || charCode == 8 || charCode == 47)
      return true;

   return false;}