Template.export.events({
  'click .export-data' () {
    let user = Meteor.user();

    Meteor.call( 'exportData', user._id, ( error, response ) => {
      if ( error ) {
        Bert.alert( error.reason, 'warning' );
      } else {
        let blob = Modules.client.convertBase64ToBlob( response );
        saveAs( blob, `${user.profile.name}.zip` );
      }
    });
  }
});
