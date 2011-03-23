(function() {
  Object.prototype.tapp = function(tag) {
    if (tag) {
      console.log("" + tag + "=", this);
    } else {
      console.log(this);
    }
    return this;
  };
  jQuery(function($) {
    $('.toggle-raw').click(function() {
      $(this).parents('td').find('.raw').toggleClass('hidden');
      return false;
    });
    return;
    return $('nav > ul > li').tapp().mouseenter(function() {
      this.tapp("over");
      return $(this).addClass('active').find('a:first').addClass('active').end().one('mouseleave', function() {
        return $(this).removeClass('active').find('a:first').removeClass('active');
      });
    });
  });
}).call(this);
