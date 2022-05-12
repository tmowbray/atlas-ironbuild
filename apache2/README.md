# opensource apache2 

This image was custom built by the DSOP Container Hardening team.  It is built on a hardened UBI8-minimal image with Apache2 HTTPD Server installed.

## Ports
This container requires port `8443` to be exposed in order to effectively run.

## Volumes
This container does not rely on a persistent or explicitly defined volume.

## Building the container
```
docker build -t tagname --no-cache .
```

## Running the container
```
docker run -d --name httpd -p 0.0.0.0:8443:8443 tagname
```

In order to use this container, you must supply your own TLS certificates by building a container built from this container.  Instructions are provided if you run the container without the necessary files installed, and in the [scripts/httpd-foreground](scripts/httpd-foreground]) file.

### Additioanal information
For additional information, visit http://httpd.apache.org/
