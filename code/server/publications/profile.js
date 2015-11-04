Meteor.publish( 'profile', function() {
  let userId = this.userId;

  return [
    Posts.find( { owner: userId } ),
    Friends.find( { owner: userId } ),
    Comments.find( { owner: userId } )
  ];
});
