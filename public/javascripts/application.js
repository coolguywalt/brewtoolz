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
    }
}
