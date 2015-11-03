Template.profile.onCreated( () => {
  Template.instance().subscribe( 'profile' );
});

Template.profile.helpers({
  name() {
    let name = Meteor.user().profile.name;
    return `${name.first} ${name.last}`;
  },
  friends() {
    let friends = Friends.find();
    if ( friends ) {
      return friends;
    }
  }
});
