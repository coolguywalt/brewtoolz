// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// detect time zone
Event.observe(window, 'load', function() {
  var date = new Date();
  date.setTime(date.getTime() + (1000*24*60*60*1000));
  var expires = "; expires=" + date.toGMTString();
  var offset = -(new Date().getTimezoneOffset() / 60);
  document.cookie = "timezone=" + offset + expires + "; path=/";
});


document.observe("dom:loaded", function() {
    // the element in which we will observe all clicks and capture
    // ones originating from pagination links
    var container = $(document.body)

    if (container) {
        container.observe('click', function(e) {
            var el = e.element()
            if (el.match('.pagination a')) {
                Hobo.showSpinner('Updating list ...')
                new Ajax.Request(el.href, {method: 'get', onComplete: function() {Hobo.hideSpinner()}})
                e.stop()  
            }
        })
    }
})

var Brewtoolz = {

    loadtab: function(el,content_div) {
        // el - element to load as tab div
        // sig - signature to to search for, signifies that the tab has not been loaded.
         
        // show the div for the tab.
        //Element.removeClassName(el, 'hidden')
        
        sig= 'no_' + content_div
        url= $('url_' + content_div).innerText


        if( $(sig) )  { // signature exists, load the partial
            new Hobo.ajaxRequest(url, Hobo.updatesForElement(content_div), {method:'put', message:false} );
        }
    },

    buttonHandler: function(button_el, handler_url) {

         var buttonData='';
         j.each( button_el.data(), function( key, value ) {
             if(!(key.match(/^ui/))) {
                 if(buttonData.length > 0) buttonData += "&";
                    buttonData += key + "=" + value;
             }
         } );

         console.log("buttonData: " + buttonData);

         Hobo.showSpinner("Allocate all from inventory");

         var request = j.ajax({
              url: handler_url,
              type: "post",
              data: buttonData
          });

           // callback handler that will be called on success
           request.done(function (response, textStatus, jqXHR){
              // log a message to the console
              console.log("Hooray, it worked!");
           });

            // callback handler that will be called on failure
            request.fail(function (jqXHR, textStatus, errorThrown){
                // log the error to the console
                console.error("The following error occured: "+
                        textStatus, errorThrown);
            });

            request.always(function () {
                Hobo.hideSpinner();
            }); 

    }
}


