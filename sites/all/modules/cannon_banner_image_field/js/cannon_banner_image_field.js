/*------------------------------------------------
 *
 * @File Cannon banner Asset Selection
 * Performs the selection for the asset store icons
 *
 *-----------------------------------------------*/
(function ($, Drupal, window, document, undefined) {
  Drupal.behaviors.cannon_banner_image_field = {
     attach: function (context, settings) {
        var $window = $(window);

        $.fn.selectBannerAsset = function(){
             var self = $(this),
             $overlay = $('<div id="banner-overlay"><div class="ajax-loader"><img src="/sites/all/modules/cannon_banner_image_field/images/gif-load.gif" /></div></div>'),
             $modal = $('.field-type-cannon-banner-url-text div.banner-modal'),
             $input,
             $images,
             $body = $('body'),
             imageSelectedFlag = false,
             loadedFlag = false,
             $close = $('.banner-modal .modal-close'),
             $select = $('.banner-modal .modal-select'),
             $srcImage = "",
             src = "",
             $thumb = $('.banner-thumb'),
             $window = $(window),
             w = $window.width(),
             h = $window.height(),
             host = "http://"+window.location.hostname;
             $select.css({'opacity':0.5});


             //here we make sure that the select button goes out and selects the images
             //this makes sure we only go out and get them if we need them
             $(this).once().click(function(e){
                var anchor = $(this);
                //append the overlay
                $body.prepend($overlay).css('overflow', 'hidden');
                $overlay.css({'opacity':0.7});

                //check to see if the images are loaded
                if(!loadedFlag){
                  //ajax call to to the back end to grab the images
                  $.ajax({
                     url: host+'/get/image/banners',
                     type: 'GET',
                     success: function(data) {
                        $('.image-container').empty();
                        $('.image-container').append(data);
                        loadedFlag = true;
                        //make sure all the events are attached to the thumbnails
                        attachEventHandlers();
                        //make sure the overlay is opened.
                        openOverlay(anchor, e);
                     },
                     error: function(data) {
                        //alert the user there was an errro
                        alert('OOPS!  An error occurred.  Contact the network admin.')
                        console.log(data);
                     }
                  });
                }else{
                  //make sure the overlay is opened.
                  openOverlay(anchor, e);
                }

             });

             //remove the banner data
             $('.banner-remove a.remove').click(function(e){
                e.preventDefault();
                $(this).parent().siblings('input').attr('value', '');
                $(this).parent().siblings('.banner-thumb').find('img').attr('src', '/sites/all/modules/cannon_banner_image_field/images/placeholder.jpg');
             });

             //this function attaches the elements that have just been loaded to event handlers
             function attachEventHandlers(){

                 //make sure and bind to all of the newly loaded images
                 $images = $('.banner-modal .image-container img');

                 //this is the select button to select an image
                 $select.once().click(function(e){
                    e.preventDefault();
                    if(imageSelectedFlag){
                      $srcImage.attr('src', src);
                      $input.attr('value', src);
                      $srcImage.css({'display':'block'});
                      closeOverlay();
                    }else{
                      return false;
                    }
                 });

                 //this handler addresses a single click on an image
                 $images.once().click(function(){
                    //send the event to the global click function
                    handleClick($(this));
                 });

                 //this handler addresses a double click on an image
                 //this handler with create a selection on an image
                 $images.dblclick(function() {
                    handleClick($(this));
                    $srcImage.attr('src', src);
                    $input.attr('value', src);
                    closeOverlay();
                 });
             }

             //the close button is present when the dom is loaded
             $close.once().click(function(e){
                e.preventDefault();
                closeOverlay();
             });

             //this function opens the overylay either after the images were loaded or on reopeing of the overlay
             function openOverlay(obj, e){
                $('.ajax-loader').css('display', 'none');
                $input = obj.siblings('input');
                $srcImage =  obj.siblings('.banner-thumb').find('img');
                e.preventDefault();
                $modal.css({'margin-top': '100px', 'margin-left': ((w/2 - 365) -40)+ 'px', 'display': 'block'});
             }

             //global click function
             //this handles highlighting an image
             function handleClick(obj){
                $images.css({'background-color':'#fff'});
                obj.css({'background-color':'#cc0000'});
                $select.css({'opacity':1.0});
                imageSelectedFlag = true;
                src = obj.attr('data-url');
             }
             //this function closes the overlay
             function closeOverlay(){
                $body.css('overflow', 'auto');
                $overlay.remove();
                $images.css({'background-color':'#fff'});
                imageSelectedFlag = false;
                $select.css({'opacity':0.5});
                $modal.fadeOut(500, function(){
                  //make sure the ajax loader is ready to display again
                  $('.ajax-loader').css('display', 'block');
                });
             }

             if(document.URL.indexOf("edit") != -1){
                $('input.cannon-banner').each(function(k, v){
                     if($(v).attr('value') != ''){
                        $(v).siblings('.banner-thumb').find('img').attr('src', $(v).attr('value'));
                     }
                });
             }

       };
       if($('a.banner').length > 0){
          $('a.banner').selectBannerAsset();
       }

     },
     detach: function(context, settings, trigger) { //this function is option


    }
  };
})(jQuery, Drupal, this, this.document);
