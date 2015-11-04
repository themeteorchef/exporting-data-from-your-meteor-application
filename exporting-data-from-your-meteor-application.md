<div class="note info">
  <h3>Pre-Written Code <i class="fa fa-info"></i></h3>
  <p><strong>Heads up</strong>: this recipe relies on some code that has been pre-written for you (like routes and templates), <a href="#">available in the recipe's repository on GitHub</a>. During this recipe, our focus will only be on implementing an export feature. If you find yourself asking "we didn't cover that, did we?", make sure to check the source on GitHub.</p>
</div>

<div class="note">
  <h3>Additional Packages <i class="fa fa-warning"></i></h3>
  <p>This recipe relies on several other packages that come as part of <a href="http://themeteorchef.com/base">Base</a>, the boilerplate kit used here on The Meteor Chef. The packages listed below are merely recipe-specific additions to the packages that are included by default in the kit. Make sure to reference the <a href="http://themeteorchef.com/base/packages-included">Packages Included list</a> for Base to ensure you have fulfilled all of the dependencies.</p>
</div>

### Getting Started

Before we write any code to get data _out_ of our application, let's get a few prerequisites installed and out of the way.

First, this recipe relies on a few NPM packages that are _not_ available via [Atmosphere](http://atmospherejs.com). While [we can set up a local Meteor package and import these](https://themeteorchef.com/snippets/using-npm-packages/#tmc-adding-an-npm-package-with-a-meteor-package) ourselves, it's much easier to use the `meteorhacks:npm` package to quickly and easily add them.

To install the `meteorhacks:npm` package, hop over to your terminal and from within your project's directory run:

<p class="block-header">Terminal</p>

```.lang-bash
meteor add meteorhacks:npm
```

This will fetch a copy of the package from Atmosphere and install it for you. When you install this package, it may ask you to restart your application. This is expected. If it does, follow any instructions on screen and then restart your application.

Next, we need to add two NPM packages using the `meteorhacks:npm` package we just installed. If everything went well installing the `meteorhacks:npm` package, you should see a new `packages.json` file in your project's root folder. Open it up and add the following:

<p class="block-header">packages.json</p>

```.lang-javascript
{
  "jszip": "2.5.0",
  "json2xml": "0.1.2"
}
```

Here, we're adding two dependencies: [JSZip](https://www.npmjs.org/package/jszip)—what we'll use to create our zip file—and [json2xml](https://www.npmjs.org/package/json2xml), what we'll use to generate an XML file on the server. Once you've updated your `packages.json` file, save it and each package will be installed.

<p class="block-header">Terminal</p>

```bash
meteor add harrison:papaparse
```

To make generating CSV files easier, we're going to add the [Papa Parse](http://papaparse.com/) library via the `harrison:papaparse` package. This will give us a one-liner for generating CSV's later (yes, that's awesome).

Before we dig in, we need one more package from Atmosphere: `pfafman:filesaver`. This Meteor package will give us access to [FileSaver.js](https://github.com/eligrey/FileSaver.js) on the client so we can actually _download_ our .zip file. To install it, hop into your terminal and run:

<p class="block-header">Terminal</p>

```.lang-bash
meteor add pfafman:filesaver
```

Wonderful! If all went as planned, we should have our dependencies locked and loaded and we can move into getting our data exported.

### Setting up an export event
Before we start handling our data, the first thing we need to do is set up an export event on the client. Our goal is to fire a request to a server-side method when our user clicks a button "Export Data" in the interface. Real quick, let's set up a template where this button will live.

<p class="block-header">/client/templates/authenticated/export.html</p>

```markup
<template name="export">
  <h3>Export</h3>
  <p>To export your data, click the button below.</p>
  <button class="export-data btn btn-success" data-loading-text="Exporting...">Export Data</button>
</template>
```

Pretty simple! Here, we have some simple instructions for our user and a button. Notice that here, we're relying on Boostrap's [loading state feature](http://getbootstrap.com/javascript/#buttons) for buttons. This is totally optional, so if you're not using Bootstrap you'll want to remove it. With this in place, let's hop over to the JavaScript file for this template where we'll actually trigger the upload.

<p class="block-header">/client/templates/authenticated/export.js</p>

```javascript
Template.export.onCreated( () => {
  Template.instance().subscribe( 'profile' );
});

Template.export.events({
  'click .export-data' ( event, template ) {
    $( event.target ).button( 'loading' );

    let user        = Meteor.user(),
        fileName    = `${user.profile.name.first} ${user.profile.name.last}`,
        profileHtml = Modules.client.getProfileHTML();

    Meteor.call( 'exportData', profileHtml, ( error, response ) => {
      // We'll handle any errors or response here.
    });
  }
});
```

Wait a minute! What's all this? There are two parts here. First, in our `export` template's `onCreated` method, we're making a call to `Template.instance().subscribe( 'profile' );`. The reason for this actually ties into our export. Because we'll be attempting to export a `.html` file with the markup of our current user's profile page, we need a way to actually _get_ that HTML. Technically, we could build this by hand on the server but that would be a pain and ultimately, not very flexible.

To get around this, we can rely on a method in Blaze—the UI framework included with Meteor—to render our template for us, returning a plain HTML string with the user's data embedded. Rad! To do this, however, we'll need to provide a _data context_ when we render the template. By loading up the subscription here, we can ensure that the method we'll define in a bit has access to the data, ensuring that our template renders without any snags.

To make this clear, let's hop over to the associated publication for this and see what it's returning.

<p class="block-header">/server/publications/profile.js</p>

```javascript
Meteor.publish( 'profile', function() {
  let userId = this.userId;

  return [
    Posts.find( { owner: userId } ),
    Friends.find( { owner: userId } ),
    Comments.find( { owner: userId } )
  ];
});

```

Pretty simple! Here, we're returning an array of cursors from our publication. Notice that for each cursor, we're passing a query specifying the field `owner`. Behind the scenes, we've [set up a few fixtures]() that load up our app with data when it starts. When those fixtures are added, we automatically assign them to a test user that we've also [defined behind the scenes](). When the fixtures are inserted, we apply the test user's ID in the `owner` field.

In our publication, then, we only want to return the documents in each collection where the `owner` field matches the currently logged in user's ID. Why? This ensures that if we login as another user later, we don't accidentally return their data as well. But wait...how do we know that the currently logged in user will be our test user? We don't!

<div class="note">
  <h3>Current User is Assumed <i class="fa fa-warning"></i></h3>
  <p>This is something to keep in mind for later. If you implement this feature in your own application, you'll want to make sure that when you add documents to the database, each one gets an <code>owner</code> field that you can reference in your queries later.</p>
</div>

Now that we have our publication and subscription setup, the next thing we want to look at is the event being fired when our user clicks the "Export Data" button.

<p class="block-header">/client/templates/authenticated/export.js</p>

```javascript
[...]

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
          // We'll handle the download here.
        }
      }
    });
  }
});
```

Next up, we need to handle two things: button state (for a little UX flair) and generating our profile as HTML. The first part is really easy. Notice that here, when our button is clicked we're firing the `.button( 'loading ' )` method we get from Bootstrap on `event.target`. Here, `event.target` corresponds to where the click event originated from, or, our `.export-data` button. Neat! When this fires, our button will display the loading text we set on the button's `data-loading-text` attribute earlier.

Great. Next up, we grab our current user and build our a string assigned to `fileName`, made up of the user's first and last name. Our goal with this is to label the zip file that will download for the user `First Last.zip` or `Peter Venkman.zip`. Just beneath this, we get to the good stuff. Here, we've assigned `profileHtml` to the result of calling `Modules.client.getProfileHTML()`. This is a [module](https://themeteorchef.com/snippets/using-the-module-pattern-with-meteor/) we've written that will help us to build out the HTML of our user's profile with the data embedded in it (remember, this is why we have the subscription to `profile` in our `export` template). Let's hop over there now and see how it's taking shape.

#### Defining an HTML export module
Remember that earlier, we explained the purpose of this step being to easily render out the HTML of user's profile with their data embedded. To get the job done, we're going to rely on Meteor's `Blaze.toHTMLWithData()` method which allows us to pass a template to render along with the data context _for_ that template. We're doing this on the client because as of writing, the method will only work client-side.

First, let's dump out the contents of our module and then explain what each step is doing.

<p class="block-header">/client/modules/get-profile-html.js</p>

```javascript
let getHTML = () => {
  let data = _getTemplateData();
  return Blaze.toHTMLWithData( Template.profile, data );
};

let _getTemplateData = () => {
  return {
    friends: _getDataFromCollection( Friends, {}, {} ),
    posts: _getDataFromCollection( Posts, {}, {} ),
    comments: _getDataFromCollection( Comments, {}, {} )
  };
};

let _getDataFromCollection = ( collection, query, filters ) => {
  let data = collection.find( query, filters );
  if ( data ) {
    return data;
  }
};

Modules.client.getProfileHTML = getHTML;
```

Ahh! Don't panic. This is pretty simple. Using [the module pattern](), we're defining a set of methods to help us accomplish three things:

1. Getting data from each of the collections used in the `profile` template.
2. Returning an object with the cursors from those collections (our data context).
3. Taking that data and passing it to a call to `Blaze.toHTMLWithData`.

The part we need to call out first is `_getTemplateData()`. Notice that this method does nothing more than return an object with three properties `friends`, `posts`, and `comments`. What do these do? Well, if we were to look at our `profile` template, we'd see that it includes some calls to helpers and has a few templates embedded in it. Here, each of these properties maps to the name of a helper that's either within the `profile` template, or, one of the nested templates. In essence, we're essentially doing this:

<p class="block-header">Example Helpers</p>

```javascript
Template.profile.helpers({
  friends() { 
    return _getDataFromCollection( Friends, {}, {} ); 
  },
  posts() { 
    return _getDataFromCollection( Posts, {}, {} ); 
  },
  comments() { 
    return _getDataFromCollection( Comments, {}, {} ); 
  }
});
```

Okay, so why use the object? This is because we'll be passing this object to our call to `Blaze.toHTMLWithData()` which will use the data directly (it won't look at the template's helpers). When the method is invoked, it will take the template name we pass along with the data and build an HTML string replacing any helpers with the matching data in the object we pass. So it's _super_ clear, `friends` in the object we're returning in `_getTemplateData()` will map to an `{{#each friends}}` loop. Make sense?

Inside of `_getTemplateData()`, we're simply calling to another method `_getDataFromCollection` which is responsible for returning the data from the collection we specify. Notice, to make this work, we're just passing along the global variable each collection is assigned to. Using this method, we can define a single function to return our data for us without having to write three separate functions. Efficient! In addition to the collection name, notice that we're also passing two empty objects. This is optional. 

We've included this here so you can see how to pass along a query and any filters you'd like. You can pull these out and omit the `query` and `filters` arguments in the `_getDataFromCollection` function if you'd like. Cool? Now, our work is pretty easy. Back up in our main `getHTML` function, we make our call to `Blaze.toHTMLWithData()`, passing the template we want to render `Template.profile` along with the data object we just built. When all is said and done, we'll get back the stringified HTML for our profile, complete with data inside. Magic!

Let's jump back over to our event handler real for our "Export Data" button real quick.

<p class="block-header">/client/templates/authenticated/export.js</p>

```javascript
[...]

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
          // We'll handle the download here.
        }
      }
    });
  }
});
```

Okay! So at this point, we've got everything we need to go to the server. Notice that in our call to `exportData`, all we're passing is the HTML string we built in our `getProfileHTML` module. Everything else we need is up on the server. Fasten your cape!

### Defining a server-side method and export module
On the server, we're going to break up the export into two steps. First, we need to define the method that we're calling from the client `exportData`. Let's get that wired up now.

<p class="block-header">/server/methods/utility/export-data.js</p>

```javascript
Meteor.methods({
  exportData( profileHtml ) {
    check( profileHtml, String );

    try {
      return Modules.server.exportData( { profileHtml: profileHtml } );
    } catch ( exception ) {
      return exception;
    }
  }
});
```
Incredibly spartan, eh? Here, we define our `exportData` method accepting a single argument `profileHtml`, corresponding to the HTML we're passing over from the client. Next, we [use the check package](https://themeteorchef.com/snippets/using-the-check-package/) to verify that our argument is a `String` and not some unwanted data. If this is successful, we set up a `try/catch` block, calling to _another_ module `exportData`. Notice that this time, we're defining the module on the server-side and we're passing a single object with a single parameter `profileHtml` as an argument. 

See what's happening here? This is just passing along the profile HTML we generated on the client. We'll make use of it next. Let's crack open that `exportData` module and get to work.

#### Defining our export module
This is the meat of our recipe. In this step, we're going to do _a lot_ of stuff. To keep our heads glued on tight, though, we're going to try to break up our code into reusable chunks. By doing this, it will be much clearer what code is responsible for what task but also, save us the need to repeat the same code over and over. First up, let's look at the definition for our module.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let json2xml = Meteor.npmRequire( 'json2xml' ),
    jsZip    = Meteor.npmRequire( 'jszip' );

let exportData = ( options ) => {
  let archive = _initializeZipArchive();
  _compileZip( archive, options.profileHtml );
  return _generateZipArchive( archive );
};

[...]

Modules.server.exportData = exportData;
```

A few things happening here. First, down at the bottom, notice that we're assigning the `exportData` function we've defined to `Modules.server.exportData`. What this is doing is helping us to namespace the `exportData` function and expose it to the server. By doing this, we can get access to `exportData` while keeping the rest of our methods in this file private. Why do that? The big reason is to avoid naming conflicts, but also because it's a bit tidier.

Up at the top, notice that we're loading in the NPM packages that we setup at the beginning of the recipe. Again, we're using these to help us export some of our data in the `XML` format and create a `.zip` archive that we can send back to the client. That may sound scary, but as we'll see, they're usage is pretty straightforward.

Inside of `exportData`, we start to get our hands dirty. First, we're calling to another method called `_initializeZipArchive()`. Here's how it looks:

<p class="block-header">/server/modules/export-data.js</p>

```javascript
[...]

let _initializeZipArchive = () => {
  return new jsZip();
};

[...]
```

Simple! Again, because we're following [the module pattern]() here, our goal is to work to get each of the functions that make up this module as small as possible. More specifically, we're trying to reduce each function down to _one task_. Why? Clarity. This makes it easy not just for us, but for other developers too, to follow the chain of thought. Here, we're simply making a call to `new jsZip()` which is creating an instance of the `jsZip` library we imported in the last step. We return this from function so we can pass it along to the rest of our methods from within our main `exportData` function.

Next, we make a call to `_compileZip()`, passing our new zip archive's instance as `archive` and also pass along our profile HTML we sent over from the client. This next step involves the bulk of the export method, so pay close attention! Let's define `_compileZip()` now and see what it's doing.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let _compileZip = ( archive, profileHtml ) => {
  let assetsFolder  = archive.folder( 'assets' );
  _addAssets( assetsFolder );
  _prepareDataForArchive( archive, Friends, 'csv', 'friends.csv' );
  _prepareDataForArchive( archive, Posts, 'xml', 'posts.xml' );
  _prepareDataForArchive( archive, Comments, 'json', 'comments.json' );
  _prepareDataForArchive( archive, profileHtml, 'html', 'profile.html' );
};
```

Don't quit! This may seem scary but it's actually just a lot of the same thing. First, we start by decalring a variable `assetsFolder`, assigning it to a call to `archive.folder( 'assets' );`. What is this doing? This is helping us to create a new folder within our zip archive called `assets`. Inside, we'll store a `CSS` file and a `JavaScript` file that will be used along with the HTML export of our user's profile. Let's define the method to do that now `_addAssets()` (notice that we're passing our new folder instance as an arugment).

<p class="block-header">/server/modules/export-data.js</p>

```javascript
[...]

let _addAssets = ( folder ) => {
  _addFileToZipArchive( folder, 'style.css', Assets.getText( 'export/style.css' ) );
  _addFileToZipArchive( folder, 'bootstrap.js', Assets.getText( 'export/bootstrap.js' ) );
};

[...]
```

Woof! [Inception time](). Again, this seems scary but when we zoom out later it will make _a lot_ more sense. Here, we're making a call to `_addFileToZipArchive()` twice (we'll define this next) passing three arguments. The location we want to save each file (this will be in our `assets` folder we created in the last step), a name to save each file as, and the contents of each file. Notice here, we're making a call to `Assets.getText()` which is looking in our project's `/private` directory for two files: `export/style.css` and `export/bootstrap.js`. This method is quite literally taking the files at these locations and grabbing their contents as text.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let _addFileToZipArchive  = ( archive, name, contents ) => {
  archive.file( name, contents );
};
```

Here, we've defined `_addFileToZipArchive()`, calling a single method `archive.file()` and passing in the name of the file to add and the contents _for_ that file. Notice, here, `archive` is equal to our `assets` folder that we've passed along. As we'll see in a bit, we'll reuse this function to store some additional files in the _root_ of our zip (not in the zip's `assets` directory). For that purpose, we've named the argument referring to the storage location `archive`. If that's confusing, follow the trail back up before moving forward.

At this point—even though we can't see it—our zip file now contains the current file structure:

```bash
/assets
-- style.css
-- bootstrap.js
```

Again, when our export is complete, we'll use these two files to help us style and add interactivity to our exported `.html` file.

Next, we need to move back up to our `_compileZip()` method to see how we're adding the rest of our files.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let _compileZip = ( archive, profileHtml ) => {
  [...]
  _prepareDataForArchive( archive, Friends, 'csv', 'friends.csv' );
  _prepareDataForArchive( archive, Posts, 'xml', 'posts.xml' );
  _prepareDataForArchive( archive, Comments, 'json', 'comments.json' );
  _prepareDataForArchive( archive, profileHtml, 'html', 'profile.html' );
};
```

Here, we see the function to end all functions being called `_prepareDataForArchive()`. Thought it may seem a bit spooky, what this is doing is helping us to save _a ton_ of extra code. Similar to the `_addFileToZipArchive()` method we just defined, this function will be responsible for grabbing the data we need for each type of export and ensure that it gets formatted correctly. Here, we can see four arguments being passed:

1. The instance of our zip archive.
2. The collection/source we want to pull data from.
3. The _format_ we want to return that data in.
4. The name of the file that will ultimately be added to our zip archive.

Down in our definition of `_prepareDataForArchive()` we can see how this takes shape.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let _prepareDataForArchive = ( archive, collection, type, fileName ) => {
  let data          = collection instanceof Mongo.Collection ? _getDataFromCollection( collection ) : collection,
      formattedData = _formatData[ type ]( data );
  _addFileToZipArchive( archive, fileName, formattedData );
};
```

Yeesh! Band-aids, my friend. Nothing more than band-aids. First, we set up a new variable `data` which includes some interesting type checking. Remember that when we invoked `_prepareDataForArchive()` every single call passed a MongoDB collection instance as the second argument _except_ for our profile HTML. Here, we check to see if what is being passed as the `collection` argument is an instance of `Mongo.Collection`. If it is, we make a call to a new function we'll define called `_getDataFromCollection()`. If it is _not_, we simply return the data directly. Feeling like a badass yet? I sure hope so.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
[...]

let _getDataFromCollection = ( collection ) => {
  let data = collection.find( { owner: Meteor.userId() } ).fetch();
  if ( data ) {
    return data;
  }
};

[...]
```

Down in our `_getDataFromCollection()` method, it's pretty much what you'd expect with two twists. First, we make a `.find()` call on the passed collection but we also make sure to pass a query to ensure that the data we get back is owned by the currently logged in user. We're doing this here for the exact same reason we did it in our publication earlier: we don't want to give other users access to other users data. Read: [don't cross the streams](https://youtu.be/jyaLZHiJJnE?t=1s). 

One last thing to point out, notice that instead of returning the MongoDB cursor directly, we're calling the `.fetch()` method which returns our data as a good ol' fashioned array. You'll see why this is important soon. Okay, back up to our `_prepareDataForArchive()` method.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let _prepareDataForArchive = ( archive, collection, type, fileName ) => {
  let data          = collection instanceof Mongo.Collection ? _getDataFromCollection( collection ) : collection,
      formattedData = _formatData[ type ]( data );
  _addFileToZipArchive( archive, fileName, formattedData );
};
```

Next up, we add another variable `formattedData` which is assigned to a call to `_formatData[]()`. This is our special sauce. Here, `_formatData` will be defined as an object with methods defined on it. In our signature here, we first call `_formatData[ type ]` using bracket notation. This is making it so that when we pass a type like `csv` or `json`, we can call the corresponding method. If this were invoked with `type` equal to `xml`, it would be like calling `_formatData.xml()`. Sooooo cool!

Pay attention to the parenthes here. These ensure that we actually _invoke_ the method that matches `type`. This also gives us a way to pass the data we grabbed in the last step. Real quick, let's set up each of the methods on `_formatData` to see how we're spitting out different file types.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
[...]

let _formatData = {
  csv( data )  { return Papa.unparse( data ); },
  xml( data )  { return json2xml( { 'posts': data }, { header: true } ); },
  json( data ) { return JSON.stringify( data, null, 2 ); },
  html( data ) {
    let header = Assets.getText( 'export/header.html' ),
        footer = Assets.getText( 'export/footer.html' );
    return header + data + footer;
  }
};

[...]
```

Let's step through each method. First, for our `csv()` method, we simply return a call to `Papa.unparse()`, passing over the data we retrieved. This method comes from the Papa Parse package `` that we installed at the beginning of the recipe. With this one-liner, we get the passed data back as a CSV formatted string. _Baller_.

Next up, `xml()`. Again, thanks to the json2xml library we added earlier, this is a one liner as well. Here, we pass two arguments: an object with a parameter `posts` which is equal to the [xml root](https://en.wikipedia.org/wiki/Root_element) element we want to wrap our list of posts with `<posts></posts>`, taking the array of data we want converted to XML. In the second position, we add a single option `header: true` to ensure that our XML file is output with an XML encoding tag `<?xml version="1.0" encoding="UTF-8"?>` (good for importing the data elsewhere later).

Third, we handle our `json()` data. Another one liner! How lucky are we? Here, we just make a call to the native `JSON.stringify()` method, passing our data and two additional arguments `null` and `2`. `null` here just lets the method know that we don't want to [replace](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#The_replacer_parameter) anything in the JSON and the `2` means that we want our string formatted with two tab-spaces. We do the latter because we want our JSON readable for our user later (instead of a single, ball of yarn string). 

Last but not least, HTML. This is pretty easy, too. Here, we make two quick calls to get the contents of `export/header.html` and `export/footer.html`. These will contain the HTML that will bookend the profile template HTML we generated earlier (notice how we're concatenating the three in the `return` statement). So it's clear, here is the result of this:

<p class="block-header">HTML export header and footer</p>

```markup
<!-- /private/export/header.html -->
<html>
<head>
  <title>Blerg | Data Export</title>
  <meta charset='utf-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1'>
  <link rel='stylesheet' type='text/css' href='assets/style.css'>
</head>
<body>
  <div class="container">
  
  <!-- our profile HTML is concatenated here -->
  
  <!-- /private/export/footer.html -->
  </div> <!-- end .container -->
  <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'></script>
  <script src='assets/bootstrap.js'></script>
</body>
</html>  
```

Something important to point out. Notice that we're including a link to `assets/style.css` and `assets/bootstrap.js` in this output. Remember, these will pont to the files we added to the `assets` directory of our zip file earlier! Pretty neat. With this in place, we're almost done with out export. Let's hop back up to our `_prepareDataForArchive()` method real quick.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
[...]

let _prepareDataForArchive = ( archive, collection, type, fileName ) => {
  let data          = collection instanceof Mongo.Collection ? _getDataFromCollection( collection ) : collection,
      formattedData = _formatData[ type ]( data );
  _addFileToZipArchive( archive, fileName, formattedData );
};

[...]
```

See what the last step is? Yep! All we're doing is reusing our `_addFileToZipArchive()` method from earlier. Here, though, instead of passing a _folder_ to the function, we pass the `archive` instance directly. This means that the files being added here will be added to the _root_ of our `.zip` file and not in a folder (like we did with `assets` earlier). Oh boy. Are you getting excited? It's okay, we're all nerds here. Get excited! Just one last step now. Let's hop back up to our main method `exportData`.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
let exportData = ( options ) => {
  let archive = _initializeZipArchive();
  _compileZip( archive, options.profileHtml );
  return _generateZipArchive( archive );
};
```

One last function. This one, we return to the client directly. Let's take a look at the definition and then call it a day on the server side.

<p class="block-header">/server/modules/export-data.js</p>

```javascript
[...]

let _generateZipArchive = ( archive ) => {
  return archive.generate( { type: 'base64' } );
};

[...]
```

That's it! In this method we make a final call to zip up our zip file with the `archive.generate()` method. Notice that here, we pass an option `type` setting it to `base64`. We're doing this here because it will make it much easier to get our zip file back to the client (other formats throw a hissy fit). Because we're returning this directly from our module (which is being returned directly from our method call), we can zip straight back to the client and finish up with downloading our zip file!

### Handling our download on the client
Okay, last two steps. First, remember that our zip file is being sent back to us in `base64` format. To make it work as a download with the filesaver.js library we added earlier, we need to convert it from `base64` into a `Blob` format (who came up with these words?). To get it done, we need to do a lot of übernerd stuff. First, so it's clear, let's see how this is positioned back in our event handler for the "Export Data" button click.

<p class="block-header">/client/templates/authenticated/export.js</p>

```javascript
[...]

Template.export.events({
  'click .export-data' ( event, template ) {
    [...]

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
```

Down in the callback of our `exportData` call, we want to pay attention to the module we're adding at `Modules.client.convertBase64ToBlob( response );`. Here, we're taking the response from the server (the `base64` version of our zip file) and passing it to the module. Let's check out the module. For the sake of time—and patience—we're going to dump out the contents and give the high-level overview instead of step-by-step.

<p class="block-header">/client/modules/convert-base64-to-blob.js</p>

```javascript
let convert = ( base64String ) => {
  let decodedString       = _decodeBase64( base64String ),
      decodedStringLength = _getLength( decodedString ),
      byteArray           = _buildByteArray( decodedString, decodedStringLength );

  if ( byteArray ) {
    return _createBlob( byteArray );
  }
};

let _decodeBase64 = ( string ) => {
  return atob( string );
};

let _getLength = ( value ) => {
  return value.length;
};

let _buildByteArray = ( string, stringLength ) => {
  let buffer = new ArrayBuffer( stringLength ),
      array  = new Uint8Array( buffer );

  for ( let i = 0; i < stringLength; i++ ) {
    array[ i ] = string.charCodeAt( i );
  }

  return array;
};

let _createBlob = ( byteArray ) => {
  return new Blob( [ byteArray ], { type: 'application/zip' } );
};

Modules.client.convertBase64ToBlob = convert;
```

Come back! This is a lot of weird stuff, for sure, but don't let it scare you. Here's the basic idea: we want to convert the `base64` string we get from the server into a `Blob` file type here on the client. To do it, we need to:

1. Decode the `base64` string.
2. Create an [array buffer](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer) based on the length of the decoded string.
3. Build a [Uint8Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint8Array) using that buffer.
4. Assign each of decoded `base64` characters to a spot _in_ that array.
5. Take that array and pass it to the `new Blob` method to get our file blob.

YIKES. This is a bit gnarly, but don't let it scare you. Just know that these are the steps necessary to go from `base64` to the `ArrayBufferView` format accepted by the `Blob()` [constructor function](https://developer.mozilla.org/en-US/docs/Web/API/Blob/Blob). The part to pay attention to is the last method in the file which we're returning directly `_createBlob`. Here, we're creating a file blob that will be accepted by filesaver.js. Notice that for `type` we're passing `application/zip`. This identifies the file as the correct [MIME-type](http://www.freeformatter.com/mime-types-list.html).

With this in place, we're almost done. Just back to our event handler to handle our file save!

<p class="block-header">/client/templates/authenticated/export.js</p>

```javascript
[...]

Template.export.events({
  'click .export-data' ( event, template ) {
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
```

Just a one-liner to seal the deal: `saveAs( blob, `${fileName}.zip` );`. Boom! Remember here, `fileName` is equal to the variable we built out of our user's first and last name earlier. From here, when our file is successfully received from the server and converted on the client, our file will download on the user's computer! Spectacular. To cap everything off, we reset our button state for the user to acknowledge the function completing.

Wipe that marshmallow of your face, Venkman. We're done!

### Wrap up & summary
Wow. What a feat. In this recipe we learned how to export data on the client as a .zip file using a server side method and modules. We learned how to export our data as CSV, XML, JSON, and HTML files as well as how to bundle them into a .zip file. Finally, we learned how to get the .zip file off the server and onto our user's computer. High fives all around!