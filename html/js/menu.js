(function($) {
    $(document).ready(function() {
        $('.navigation').prepend('<div id="hamburger">Navigation</div>');
        $('#hamburger').on('click', function() {
            $(this).addClass('hide');
            var menu = $(this).next('ul');
            if (menu.hasClass('open')) {
                menu.removeClass('open');
            } else {
                menu.addClass('open');
            }
        });
    });
})(jQuery);