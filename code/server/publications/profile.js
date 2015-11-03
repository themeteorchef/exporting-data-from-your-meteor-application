Meteor.publish( 'profile', function() {
  return [
    Posts.find(),
    Friends.find(),
    Comments.find()
  ];
});
