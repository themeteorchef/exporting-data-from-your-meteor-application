let administrators = [
  {
    email: 'venkman@ghostbusters.com',
    password: 'slimer',
    profile: {
      name: { first: 'Peter', last: 'Venkman' },
      photo: 'https://tmc-post-content.s3.amazonaws.com/peter-venkman.jpg',
      location: 'New York, NY',
      career: 'Scientist, Ghostbuster',
      biography: 'I was born in Brooklyn, New York. I\'m one of three doctors of parapsychology on the Ghostbusters team. I hold PhDs in both parapsychology and psychology.'
    }
  }
];

let generateAccounts = () => {
  let usersExist = _checkIfAccountsExist( administrators.length );

  if ( !usersExist ) {
    _createUsers( administrators );
  }
};

let _checkIfAccountsExist = ( count ) => {
  let userCount = Meteor.users.find().count();
  return userCount < count ? false : true;
};

let _createUsers = ( users ) => {
  for ( let i = 0; i < users.length; i++ ) {
    let user       = users[ i ],
        userExists = _checkIfUserExists( user.email );

    if ( !userExists ) {
      _createUser( user );
    }
  }
};

let _checkIfUserExists = ( email ) => {
  return Meteor.users.findOne( { 'emails.address': email } );
};

let _createUser = ( user ) => {
  Accounts.createUser({
    email: user.email,
    password: user.password,
    profile: user.profile
  });
};

Modules.server.generateAccounts = generateAccounts;
