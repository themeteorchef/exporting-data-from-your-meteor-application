Template.export.onCreated( () => {
  Template.instance().subscribe( 'profile' );
});

Template.export.events({
  'click .export-data' ( event, template ) {
    $( event.target ).button( 'loading' );

    let name        = Meteor.user().profile.name,
        fileName    = `${name.first} ${name.last}`,
        profileHtml = Modules.client.getProfileHTML();

    Meteor.call( 'exportData', profileHtml, ( error, response ) => {
      if ( error ) {
        Bert.alert( error.reason, 'warning' );
      } else {
        if ( response ) {
          let blob = Modules.client.convertBase64ToBlob( response );
          saveAs( blob, `${fileName}.zip` );
          $( event.target ).button( 'reset' );
        }
      }
    });
  }
});
