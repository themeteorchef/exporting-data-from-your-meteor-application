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
  return new Blob( [ byteArray ], { type: 'zip' } );
};

Modules.client.convertBase64ToBlob = convert;
