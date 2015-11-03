let json2xml = Meteor.npmRequire( 'json2xml' ),
    jsZip    = Meteor.npmRequire( 'jszip' );

let exportData = ( options ) => {
  let archive = _initializeZipArchive();
  _compileZip( archive, options.profileHtml );
  return _generateZipArchive( archive );
};

let _addAssets = ( folder ) => {
  _addFileToZipArchive( folder, 'style.css', Assets.getText( 'export/style.css' ) );
  _addFileToZipArchive( folder, 'bootstrap.js', Assets.getText( 'export/bootstrap.js' ) );
};

let _compileZip = ( archive, profileHtml ) => {
  let assetsFolder  = archive.folder( 'assets' );
  _addAssets( assetsFolder );
  _prepareDataForArchive( archive, Friends, 'csv', 'friends.csv' );
  _prepareDataForArchive( archive, Posts, 'xml', 'posts.xml' );
  _prepareDataForArchive( archive, Comments, 'json', 'comments.json' );
  _prepareDataForArchive( archive, profileHtml, 'html', 'profile.html' );
};

let _prepareDataForArchive = ( archive, collection, type, fileName ) => {
  let data          = collection instanceof Mongo.Collection ? _getDataFromCollection( collection ) : collection,
      formattedData = _formatData[ type ]( data );
  _addFileToZipArchive( archive, fileName, formattedData );
};

let _getDataFromCollection = ( collection ) => {
  let data = collection.find( { owner: Meteor.userId() } ).fetch();
  if ( data ) {
    return data;
  }
};

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

let _initializeZipArchive = () => {
  return new jsZip();
};

let _addFileToZipArchive  = ( archive, name, contents ) => {
  archive.file( name, contents );
};

let _generateZipArchive   = ( archive ) => {
  return archive.generate( { type: 'base64' } );
};

Modules.server.exportData = exportData;
