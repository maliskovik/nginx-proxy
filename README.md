# Ngixn proxy.
Refer to [jwilder-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/) for documentation.

## Using with other projects

### Intro

When docker-compose runs it's services it by-default creates a new network, to which it connects all the created containers. This means that 2 sets of containers created with different docker-compose files(2 different projects), can not see each other. Because of this with docker-compose v2, proxy container could not connect to other projects - by default.

### Working with networks - the right way
#### First things first
Run the proxy container. If you already have a docker container named "proxy" on your system, remove it, we won't be needing it any more.  
Then just:
```
docker-compose up -d
```
And you have an new proxy up and running.  
This of course also created a new network called `proxy_default` in which proxy container resides. To have any other container connect to it(and vice-versa), we must add it to this network.

#### Adding other containers to this network.
Since we don't wish to leave networking on our new project to composes auto config, we need to do 2 things:
* Define networks in the docker compose file.
* List which networks a container should connect to.

In the new docker-compose.yml file we will add a section to the root of the document(same depth as "services" or "version") called "networks":
```
networks:
  proxy_default:
    external:
      name: proxy_default
```
Here we created a network proxy_default, which represents an already existing proxy_default network. That's all wee need to do to be able to use this network.

Then we need to add containers to this network. Under services which will connect to this network add the networks section as in the example below:
```
api:
  image: nginx
  environment:
    - VIRTUAL_HOST=example.local
  networks:
    - default
    - proxy_default
```
This api container will now be connected to the proxy_default network as well as the default network that will be created for this project by docker-compose.  
Only the container which needs to connect to the proxy container should be connected to his network, other containers will connect to the default network by default and need no explicit configuration.

## Backward compatibility
Unfortunatelly, it's not possible, to set the existing bridge network in the docker-compose.yml file, but it is possible to connect the proxy container to the bridge network after it is created:
```
docker network connect bridge proxy
```
