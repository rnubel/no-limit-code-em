//= require jquery
//= require_self

$(function() {
  $('.field').placeHeld();

  // refresh the data
  setInterval(function() {
    $('.loader').fadeIn();
    $.ajax({
      url: '/tournaments/refresh',
      type: 'GET'
    });
  }, 12000);
});

// input placeholders
(function(a){a.placeHeld=function(c,b){var d=this;d.$el=a(c);d.el=c;d.$el.data("placeHeld",d);d.placeholderText=d.$el.attr("placeholder");d.init=function(){d.options=a.extend({},a.placeHeld.defaultOptions,b);d.$el.bind("blur",d.holdPlace).bind("focus",d.releasePlace).trigger("blur");d.$el.parents("form").bind("submit",d.clearPlace)};d.holdPlace=function(){var e=d.$el.val();if(!e){d.$el.val(d.placeholderText).addClass(d.options.className)}};d.releasePlace=function(){var e=d.$el.val();if(e==d.placeholderText){d.$el.val("").removeClass(d.options.className)}};d.clearPlace=function(){var e=d.$el.val();if(e==d.placeholderText&&d.$el.hasClass(d.options.className)){d.$el.val("")}};d.init()};a.placeHeld.defaultOptions={className:"placeheld"};a.fn.placeHeld=function(b){if(!!("placeholder" in a("<input>")[0])){return}return this.each(function(){(new a.placeHeld(this,b))})}})(jQuery);
