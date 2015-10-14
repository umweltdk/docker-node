# umweltdk/node docker image [![travis](https://travis-ci.org/umweltdk/docker-node.svg?branch=master)](https://travis-ci.org/umweltdk/docker-node)

[![dockeri.co](http://dockeri.co/image/umweltdk/node)](https://hub.docker.com/r/umweltdk/node/)

A simple docker image that supports building, testing and exporting the build content as a tar.

# Supported tags and respective `Dockerfile` links

- [`0.12.7`, `0.12`, `0` (*Dockerfile*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile)
- [`0.12.7-onbuild`, `0.12-onbuild` (*Dockerfile.onbuild*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild)
- [`0.12.7-onbuild-bower`, `0.12-onbuild-bower` (*Dockerfile.onbuild-bower*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild-bower)
- [`4.1.2`, `4.1` (*Dockerfile*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile)
- [`4.1.2-onbuild`, `4.1-onbuild` (*4.1/onbuild/Dockerfile*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild)
- [`4.1.2-onbuild-bower`, `4.1-onbuild-bower` (*Dockerfile.onbuild-bower*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild-bower)
- [`4.2.1`, `4.2`, `4`, `latest` (*Dockerfile*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile)
- [`4.2.1-onbuild`, `4.2-onbuild`, `4-onbuild`, `onbuild` (*4.1/onbuild/Dockerfile*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild)
- [`4.2.1-onbuild-bower`, `4.2-onbuild-bower`, `4-onbuild-bower`, `onbuild-bower` (*Dockerfile.onbuild-bower*)](https://github.com/umweltdk/docker-node/blob/master/Dockerfile.onbuild-bower)

## How to use this image

Create a Dockerfile in your Node.js app project

```
FROM umweltdk/node:0.12-onbuild
# replace this with your application's default port
EXPOSE 8888
````

Build an image for your app

```
$ docker build -t my-nodejs-app .
```

### Running tests

```
$ docker run -it --rm my-nodejs-app test
```

### Running the app

```
$ docker run -it --rm --name my-running-app my-nodejs-app
```

### Exporting build product

To export a tar of the built app directory:

```
$ docker run --rm my-nodejs-app slug - > app.tar.gz
```

 Use this if you want to upload a site to something like S3.

# Image Variants

The `node` images come in many flavors, each designed for a specific use case.

## `node:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of. This tag is based off of [`node`](https://registry.hub.docker.com/_/node/) but adds a user, so everything is not run as root and an entrypoint to support testing and export the build product.

## `node:onbuild`

This image makes building derivative images easier. For most use cases, creating a `Dockerfile` in the base of your project directory with the line `FROM node:onbuild` will be enough to create a stand-alone image for your project.

While the `onbuild` variant is really useful for "getting off the ground running" (zero to Dockerized in a short period of time), it's not recommended for long-term usage within a project due to the lack of control over *when* the `ONBUILD` triggers fire (see also [`docker/docker#5714`](https://github.com/docker/docker/issues/5714), [`docker/docker#8240`](https://github.com/docker/docker/issues/8240), [`docker/docker#11917`](https://github.com/docker/docker/issues/11917)).

Once you've got a handle on how your project functions within Docker, you'll probably want to adjust your `Dockerfile` to inherit from a non-`onbuild` variant and copy the commands from the `onbuild` variant `Dockerfile` (moving the `ONBUILD` lines to the end and removing the `ONBUILD` keywords) into your own file so that you have tighter control over them and more transparency for yourself and others looking at your `Dockerfile` as to what it does. This also makes it easier to add additional requirements as time goes on (such as installing more packages before performing the previously-`ONBUILD` steps).

## `node:onbuild-bower`

This image is very much like the onbuild variant except that it has an ONBUILD line for doing ```bower install``` which means that the caching will be better when you use bower and you use this image.

