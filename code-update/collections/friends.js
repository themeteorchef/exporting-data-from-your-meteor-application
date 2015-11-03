Friends = new Meteor.Collection( 'friends' );

Friends.allow({
  insert: () => false,
  update: () => false,
  remove: () => false
});

Friends.deny({
  insert: () => true,
  update: () => true,
  remove: () => true
});

let FriendsSchema = new SimpleSchema({
  "owner": {
    type: String,
    label: "The ID of the owner of this document."
  },
  "photo": {
    type: String,
    label: "The URL of the avatar for this friend."
  },
  "name": {
    type: String,
    label: "The name of this friend."
  }
});

Friends.attachSchema( FriendsSchema );
