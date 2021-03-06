/*------------------------------------------------
 *
 * @File Cannon Media Valet
 * Performs the selection for media valet icons
 *
 *-----------------------------------------------*/
(function ($, Drupal, window, document, undefined) {
  Drupal.behaviors.cannon_media_valet_image_field = {
     attach: function (context, settings) {
        var $window = $(window);


        $.fn.selectMediaValetAsset = function(){
             var self = $(this),
             $overlay = $('<div id="media-valet-overlay"><div class="ajax-loader"><img src="/sites/all/modules/cannon_media_valet_image_field/images/gif-load.gif" /></div></div>'),
             $modal = $('.field-type-cannon-media-valet-url-text div.media-valet-modal'),
             $input,
             $body = $('body'),
             imageSelectedFlag = false,
             loadedFlag = false,
             $close = $('.media-valet-modal .modal-close'),
             $select = $('.media-valet-modal .modal-select'),
             $images,
             $srcImage,
             src = "",
             $thumb = $('.media-valet-thumb'),
             $window = $(window),
             w = $window.width(),
             h = $window.height();
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
                     url: host+'/get/image/assets',
                     type: 'GET',
                     success: function(data) {

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
             $('.media-remove a.remove').click(function(e){
                e.preventDefault();
                $(this).parent().siblings('input').attr('value', '');
                $(this).parent().siblings('.media-valet-thumb').find('img').attr('src', '/sites/all/modules/cannon_banner_image_field/images/placeholder.jpg');
             });

             //this function attaches the elements that have just been loaded to event handlers
             function attachEventHandlers(){

                 //make sure and bind to all of the newly loaded images
                 $images = $('.media-valet-modal .image-container img');

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

             $close.once().click(function(e){
                e.preventDefault();
                closeOverlay();
             });

            //this function opens the overylay either after the images were loaded or on reopeing of the overlay
             function openOverlay(obj, e){
                $('.ajax-loader').css('display', 'none');
                $input = obj.siblings('input');
                $srcImage =  obj.siblings('.media-valet-thumb').find('img');
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

             /*
             $(context).ajaxSuccess(function(e){
                if(e.target.id === "color-stream-node-form"){
                  $(context).find('input.cannon-media-valet').each(function(k, v){
                     if($(v).attr('value') != ''){
                        $(v).siblings('.media-valet-thumb').find('img').attr('src', $(v).attr('value'));
                     }
                  });
                }
             }); */

             if(document.URL.indexOf("edit") != -1){
                $('input.cannon-media-valet').each(function(k, v){
                     if($(v).attr('value') != ''){
                        $(v).siblings('.media-valet-thumb').find('img').attr('src', $(v).attr('value'));
                     }
                });
             }

       };
       if($('a.media-valet').length > 0){
          $('a.media-valet').selectMediaValetAsset();
       }

     },
     detach: function(context, settings, trigger) { //this function is option


    }
  };
})(jQuery, Drupal, this, this.document);
