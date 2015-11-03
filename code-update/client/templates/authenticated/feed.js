Template.feed.helpers({
  posts() {
    let posts = Posts.find();
    if ( posts ) {
      return posts;
    }
  },
  comments() {
    let comments = Comments.find();
    if ( comments ) {
      return comments;
    }
  }
});
