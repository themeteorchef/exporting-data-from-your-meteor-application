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
