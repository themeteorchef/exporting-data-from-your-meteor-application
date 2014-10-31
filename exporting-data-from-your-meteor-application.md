<span class="intro-text">I recently decided to close the doors on a piece of software I released last year. Before I shut it down, I wanted to make sure that the ability to export data was avaiable. In this recipe, I want to share what I learned and teach you how to add an export tool to your own application so users can get their data out.</span>

### Getting Started

Before we write any code to get data out of our application, let's get a few prerequisites installed and out of the way.

First, this recipe relies on a new NPM packages that are _not_ available via [Atmosphere](http://atmospherejs.com). While we can setup a local Meteor package and import these ourselves, it's much easier to use the `meteorhacks:npm` package to quickly and easily add them.

To install the `meteorhacks:npm` package, hop over to your terminal and from within your project's directory run:

<p class="block-header">Terminal</p>

```.lang-javascript
 meteor add meteorhacks:npm
```

This will fetch a copy of the package from Atmosphere and install it for you.

Next, we need to get our packages installed via NPM. If everything went well installing the `meteorhacks:npm` package, you should see a new `packages.json` file in your project's root folder. Open it up and add the following:

<p class="block-header">packages.json</p>
```.lang-javascript
{
  "jszip": "2.4.0",
  "xmlbuilder": "2.4.4",
  "fast-csv": "0.5.3"
}
```

Here, we're adding three dependencies: [JSZip](https://www.npmjs.org/package/jszip) (what we'll use to create our zip file), [XML Builder](https://www.npmjs.org/package/xmlbuilder) (what we'll use to export an XML file), and [Fast CSV](https://www.npmjs.org/package/fast-csv) (what we'll use to export a CSV file). Once you've updated your `packages.json` file, save it and each package will be installed.

Before we dig in, we need one more package from Atmosphere: `pfafman:filesaver`. This Meteor package will give us access to [FileSaver.js](https://github.com/eligrey/FileSaver.js) on the client so we can actually _download_ our .zip file. To get installed, hop into your terminal and run:

<p class="block-header">Terminal</p>

```.lang-javascript
 meteor add pfafman:filesaver
```

Wonderful! If all went as planned, we should have our dependencies locked and loaded and we can move into getting our data exported.

### Setting Up Collections
This section will go over setting up the necessary collections and seeding them with data we can export.

### Routing & Templates
This section will go over setting up the necessary routes in our application to handle exporting.

### Installing NPM Packages
This section will go over installing the NPM packages required to get exports working.

### Defining & Calling Server Methods
This section will go over setting up our Method on the client and the server.

### Exporting as XML
This section will go over exporting data in a .XML format.

### Exporting as HTML
This section will go over exporting data in .HTML format.
- Remark on CSS.
- Remark on UTF-8.

### Exporting as .CSV
This section will go over exporting data in .CSV format.
- Remark on sanitizing data to strip commas.

### Creating & Sending .ZIP data to the Client
This section will go over setting up a .zip directory on the server and populating it with folders and files.

### Downloading a .ZIP file on the Client
This section will go over downloading a .zip directory on the client.

<div class="what-we-will-learn">
    <h3>In This Recipe We Learned</h3>
    <ul>
        <li>How to setup collections and seed them with data.</li>
        <li>How to set up the necessary routes and templates for exporting data.</li>
        <li>How to add NPM modules to give us extra functionality.</li>
        <li>How to get our data out of MongoDB and into a file on the server.</li>
        <li>How to create XML, HTML, and CSV files on the server.</li>
        <li>How to pass files from the server to the client.</li>
        <li>How to download a .zip file on the client using FileSaver.js.</li>
    </ul>
</div>