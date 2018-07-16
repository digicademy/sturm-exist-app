/* 
 * DER STURM
 * A Digital Edition of Sources from the International Avantgarde
 *
 * Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 * Academy of Sciences and Literature | Mainz
 *
 * Mobile navigation.
 *
 * @author Torsten Schrade
 * @email <Torsten.Schrade@adwmainz.de>
 * @licence MIT
 */

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