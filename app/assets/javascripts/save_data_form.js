var submit_form_okey = false;
var form1;
$(document).ready(function(){ 
  form1 = $("form.edit_user").serialize();  
});

 $('.form_testing').on("click",function(e){
    e.preventDefault();
    e.stopPropagation();
    location.href = $(this).attr("href");
   });
window.onbeforeunload = function () {
  var form2 = $("form.edit_user").serialize();
  if (submit_form_okey == false && (form1 != form2 )) {
    return "Are you sure you want to leave without save data?";
  }
}