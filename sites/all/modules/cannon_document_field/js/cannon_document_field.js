/*------------------------------------------------
 *
 * @File Cannon document Asset Selection
 * Performs the selection for the asset store icons
 *
 *-----------------------------------------------*/
(function ($, Drupal, window, document, undefined) {
  Drupal.behaviors.cannon_document_field = {
     attach: function (context, settings) {
       var $window = $(window);

        $.fn.selectLogoAsset = function(){
             var self = $(this),
             $overlay = $('<div id="document-overlay"><div class="ajax-loader"><img src="/sites/all/modules/cannon_document_field/images/gif-load.gif" /></div></div>'),
             $modal = $('.field-type-canon-document-url-text div.document-modal'),
             $input,
             $images,
             $body = $('body'),
             imageSelectedFlag = false,
             loadedFlag = false,
             $close = $('.document-modal .modal-close'),
             $select = $('.document-modal .modal-select'),
             $srcImage = "",
             src = "",
             imgSrc = "",
             $title = $('.document-title'),
             title_string = "",
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
                     url: host+'/get/image/documents',
                     type: 'GET',
                     success: function(data) {

                        $('document.image-container').append(data);
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

             //this function attaches the elements that have just been loaded to event handlers
             function attachEventHandlers(){

                 //make sure and bind to all of the newly loaded images
                 $images = $('.document-modal .image-container img');

                 //this is the select button to select an image
                 $select.once().click(function(e){
                    e.preventDefault();
                    if(imageSelectedFlag){
                      $srcImage.attr('src', imgSrc);
                      $input.attr('value', src);
                      $title.text(title_string);
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
                    $srcImage.attr('src', imgSrc);
                    $input.attr('value', src);
                    $title.text(title_string);
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
                $srcImage =  obj.siblings('.document-thumb').find('img');
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
                imgSrc = obj.attr('src');
                title_string = obj.siblings('div').text();
                src = src + '||||' + title_string;
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
                $('input.cannon-document').each(function(k, v){
                     if($(v).attr('value') != ''){
                        $(v).siblings('.document-thumb').find('img').attr('src', $(v).attr('value'));
                     }
                });
             }

       };

       if($('a.document').length > 0){
          $('a.document').selectLogoAsset();
       }

     },
     detach: function(context, settings, trigger) { //this function is option


    }
  };
})(jQuery, Drupal, this, this.document);
