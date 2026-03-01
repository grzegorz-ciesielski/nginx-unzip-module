## What is this?

An nginx module that enables serving files stored in ZIP archives on-the-fly without extracting the entire archive into memory.

## Nginx configuration directives

* file_in_unzip - enables the module for the location
* file_in_unzip_archivefile - path to the ZIP archive file
* file_in_unzip_extract - path to the file within the archive to extract
* file_in_unzip_chunk_size - streaming buffer size in bytes (default: 256KB, optional)

## Configuration example

<pre>
  location ~ ^/(.+?\.zip)/(.*)$ {
      file_in_unzip;
      file_in_unzip_archivefile "$document_root/$1";
      file_in_unzip_extract "$2";
      file_in_unzip_chunk_size 262144;
  }
</pre>
