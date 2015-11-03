Meteor.methods({
  exportData( profileHtml ) {
    check( profileHtml, String );

    try {
      return Modules.server.exportData( { profileHtml: profileHtml } );
    } catch ( exception ) {
      return exception;
    }
  }
});
