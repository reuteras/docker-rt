# docker-rt

[RT](https://www.bestpractical.com/rt/), or Request Tracker, is a issue tracking system. Currently build RT lastest (4.4.x) and RT 4.2.12.

## Features

In this first build this container makes some assuptions that might not be for everyone. The database used is Postgresql. You have to use SSL and add the following files at startup:

* RT_SiteConfig.pm
* server-chain.pem
* server.pem

## Usage

To run docker-rt (change to your full path to files specified above):

        docker run -ti -p 443:443 -e RT_HOSTNAME=rt.example.com -e RT_RELAYHOST=mail.example.com -v /<full path>/docker-rt/files:/data --name rt -d reuteras/docker-rt

* `-e RT_HOSTNAME=<RT server hostname>`
* `-e RT_RELAYHOST=<Postfix relay host>`

## Upgrade from 4.2.12 to 4.4.x

The steps I took:

    # Backup database first
    docker stop rt
    run -ti -p 443:443 -e RT_HOSTNAME=<hostname> -e RT_RELAYHOST=<host> -v /docker:/data:ro --name rt44 -d reuteras/docker-rt
    docker exec -ti rt44 /bin/bash
    rt# cd /opt/rt4
    rt# ./rt-setup-database --action upgrade
    rt# exit
    # Clean up and restart with correct name
    docker stop rt44
    docker rm rt
    docker rm rt44
    run -ti -p 443:443 -e RT_HOSTNAME=<hostname> -e RT_RELAYHOST=<host> -v /docker:/data:ro --name rt -d reuteras/docker-rt

## TODO
Lots of things.

* Update README with information on how to init and update the database
* Solution for adding plugins
