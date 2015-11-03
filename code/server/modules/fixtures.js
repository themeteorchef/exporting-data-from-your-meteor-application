let fixtures = {
  friends: [
    {
      "photo": "https://tmc-post-content.s3.amazonaws.com/ray-stantz.jpg",
      "name": "Ray Stantz"
    },
    {
      "photo": "https://tmc-post-content.s3.amazonaws.com/egon-spengler.jpg",
      "name": "Egon Spengler"
    },
    {
      "photo": "https://tmc-post-content.s3.amazonaws.com/winston-zeddemore.jpg",
      "name": "Winston Zeddemore"
    }
  ],
  posts: [
    {
      "text": "Thinking about visiting Dana and Oscar later on tonight.",
      "name": "Peter Venkman",
      "date": "October 15th, 2015"
    },
    {
      "text": "Still have slime on my hands from the library. Still.",
      "name": "Peter Venkman",
      "date": "October 14th, 2015"
    },
    {
      "text": "Ordered a copy of Magical Paths to Fortune and Power from Ray's. Ready to be rich beyond my wildest dreams.",
      "name": "Peter Venkman",
      "date": "October 13th, 2015"
    }
  ],
  comments: [
    {
      "avatar": "https://tmc-post-content.s3.amazonaws.com/ray-stantz.jpg",
      "commenterName": "Ray Stantz",
      "commentDate": "October 22nd, 2015",
      "commentContent": "Hey, Peter! I got your book in at the shop: Magical Paths to Fortune and Power. Swing by when you can to pick it up."
    },
    {
      "avatar": "https://tmc-post-content.s3.amazonaws.com/egon-spengler.jpg",
      "commenterName": "Egon Spengler",
      "commentDate": "October 20th, 2015",
      "commentContent": "My ears really hurt after you slammed that book on the table. Thanks for that."
    },
    {
      "avatar": "https://tmc-post-content.s3.amazonaws.com/winston-zeddemore.jpg",
      "commenterName": "Winston Zeddemore",
      "commentDate": "October 19th, 2015",
      "commentContent": "Still can't believe Ray didn't say he was a god. What a mess!"
    }
  ]
};

Modules.server.fixtures = {
  friends: fixtures.friends,
  posts: fixtures.posts,
  comments: fixtures.comments
};
