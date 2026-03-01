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

## Building the module

### Using Docker

Build as static module:
```bash
docker build --progress=plain -t nginx-unzip-builder .
```

Build as dynamic module:
```bash
docker build --progress=plain --build-arg MODULE_TYPE=dynamic -t nginx-unzip-builder .
```

Extract dynamic module:
```bash
docker create --name builder-temp nginx-unzip-builder:latest
docker cp builder-temp:/usr/lib64/nginx/modules/ngx_http_unzip_module.so ./
docker rm builder-temp
```

### Custom nginx version

Override the default nginx version (1.28.2):
```bash
docker build --progress=plain --build-arg NGINX_VERSION=1.26.0 -t nginx-unzip-builder .
```
