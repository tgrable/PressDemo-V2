/*------------------------------------------------
 *
 * @File Cannon Media Valet
 * Performs the selection for media valet icons
 *
 *-----------------------------------------------*/
(function ($, Drupal, window, document, undefined) {
  Drupal.behaviors.cannon_media_valet_video_field = {
     attach: function (context, settings) {

        $.fn.selectMediaValetAsset = function(){
           var self = $(this),
           $overlay = $('<div id="media-valet-overlay"></div>'),
           $modal = $('.field-type-cannon-media-valet-video-field-video-url-text div#media-valet-modal'),
           $input = $('input.cannon-media-valet'),
           $body = $('body'),
           videoSelectedFlag = false,
           $close = $('.modal-close'),
           $select = $('.modal-select'),
           $videos = $('.video-container img'),
           $srcImage = $('#media-valet-thumb img'),
           src = "",
           videoURL = "";
           $thumb = $('#media-valet-thumb'),
           $window = $(window),
           w = $window.width(),
           h = $window.height();

           $select.css({'opacity':0.5});

           $(this).click(function(e){
              e.preventDefault();
              $body.prepend($overlay).css('overflow', 'hidden');
              $overlay.css({'opacity':0.7});
              $modal.css({'margin-top': '100px', 'margin-left': ((w/2 - 365) -40)+ 'px', 'display': 'block'});

           });

           $select.click(function(e){
              e.preventDefault();
              if(videoSelectedFlag){
                $srcImage.attr('src', src);
                $input.attr('value', videoURL);
                closeOverlay();
              }else{
                return false;
              }
           });

           $close.click(function(e){
              e.preventDefault();
              closeOverlay();
           });

           $videos.click(function(){
              handleClick($(this));
           });

           $videos.dblclick(function() {
              handleClick($(this));
              $srcImage.attr('src', src);
              $input.attr('value', videoURL);
              $thumb.prepend($srcImage);
              closeOverlay();
           });

           function handleClick(obj){
              $videos.css({'background-color':'#fff'});
              obj.css({'background-color':'#cc0000'});
              $select.css({'opacity':1.0});
              imageSelectedFlag = true;
              src = obj.attr('src');
              videoURL = obj.attr('data-url') + '||||'+ src + '||||' + obj.attr('data-source');
           }

           function closeOverlay(){
              $body.css('overflow', 'auto');
              $overlay.remove();
              $videos.css({'background-color':'#fff'});
              videoSelectedFlag = false;
              $select.css({'opacity':0.5});
              $modal.fadeOut(500);
           }

        };
        if($('#media-valet').length > 0){
          $('#media-valet').selectMediaValetAsset();
        }
     }
  };
})(jQuery, Drupal, this, this.document);
