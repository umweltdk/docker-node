# Source of griff/node-builder docker image

A simple docker image that supports building testing and exporting a zip
suitable for deploy to elastic beanstalk.

## How to use this image

Create a Dockerfile in your Node.js app project

```
FROM griff/node-build:0.12
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

### Exporting elastic beanstalk zip

To export a zip that can be deployed to elastic beanstalk run the command:

```
$ docker run --rm my-nodejs-app eb-export > app.zip
```


