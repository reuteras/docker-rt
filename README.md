# docker-rt

[RT](https://www.bestpractical.com/rt/), or Request Tracker, is a issue tracking system. Currently build RT lastest (4.4.x) and RT 4.2.12.

## Features

In this first build this container makes some assumptions that might not be for everyone. The container is only built to use Postgresql. You also have to use SSL/TLS and have a directory with the following files shared with the container at startup:

* RT_SiteConfig.pm
* server-chain.pem
* server.pem

## Usage

To run docker-rt (change to <full path> to the location of the files specified above):

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
    rt# ./sbin/rt-setup-database --action upgrade
    rt# exit
    # Clean up and restart with correct name
    docker stop rt44
    docker rm rt
    docker rm rt44
    run -ti -p 443:443 -e RT_HOSTNAME=<hostname> -e RT_RELAYHOST=<host> -v /docker:/data:ro --name rt -d reuteras/docker-rt

The same steps can be used for upgrades from 4.4.x to 4.4.y where y>x.

## Install

In my environment I still use an vm to run Postgresql. Because of that I haven't scripted any default setup to automatically use a linked database container. Something like the following should help you get started.

    # Change mysecretpassword to something better
    docker run --name postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
    docker inspect postgres | grep IPAddress
    # edit RT_SiteConfig.pm and insert the IP Address
    docker run -ti -p 443:443 -e RT_HOSTNAME=servername -e RT_RELAYHOST=servername -v $(pwd)/files:/data --name rt -d reuteras/docker-rt
    docker exec -ti rt /bin/bash
    # in the container
    cd /tmp/rt/rt-4.4.*
    make initdb
    # enter password from step one
    exit

## TODO
Lots of things.

* Solution for adding plugins

