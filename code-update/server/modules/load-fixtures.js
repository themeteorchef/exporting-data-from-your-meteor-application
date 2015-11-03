let load = () => {
  let owner = _getOwner( 'venkman@ghostbusters.com' );
  _insertContent( Friends, owner._id, Modules.server.fixtures.friends );
  _insertContent( Posts, owner._id, Modules.server.fixtures.posts );
  _insertContent( Comments, owner._id, Modules.server.fixtures.comments );
};

let _getOwner = ( emailAddress ) => {
  let owner = Meteor.users.findOne( { 'emails.address': emailAddress }, { fields: { emails: 1 } } );
  if ( owner ) {
    return owner;
  }
};

let _insertContent = ( collection, owner, data ) => {
  let dataExists = _checkIfDataExists( collection );

  if ( !dataExists ) {
    for ( let i = 0; i < data.length; i++ ) {
      let item = data[ i ];
      item.owner = owner;
      collection.insert( item );
    }
  }
};

let _checkIfDataExists = ( collection ) => {
  let itemCount = collection.find().count();
  return itemCount > 0 ? true : false;
};

Modules.server.loadFixtures = load;
