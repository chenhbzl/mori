// Sets the require.js configuration for your application.
require.config( {
  paths: {
    "jquery": "libs/jquery",
    "jquerymobile": "libs/jquerymobile",
    "underscore": "libs/lodash",
    "backbone": "libs/backbone"
  },
  // Sets the configuration for your third party scripts that are not AMD compatible
  shim: {
    "backbone": {
      "deps": [ "underscore", "jquery" ],
      "exports": "Backbone"  //attaches "Backbone" to the window object
     }
  }
} );

// Includes File Dependencies
require([ "jquery", "backbone", "routers/mobileRouter" ], function( $, Backbone, Mobile ) {
  $(document).on( "mobileinit",
    // Set up the "mobileinit" handler before requiring jQuery Mobile's module
    function() {
	// Prevents all anchor click handling including the addition of active button state and alternate link bluring.
	$.mobile.linkBindingEnabled = false;
	// Disabling this will prevent jQuery Mobile from handling hash changes
	$.mobile.hashListeningEnabled = false;
    }
  )

  require( [ "jquerymobile" ], function() {
   // Instantiates a new Backbone.js Mobile Router
   this.router = new Mobile();
  });
} );
