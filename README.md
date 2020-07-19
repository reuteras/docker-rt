# docker-rt

[![Docker Pulls](https://img.shields.io/docker/pulls/reuteras/docker-rt.svg?style=plastic)](https://hub.docker.com/r/reuteras/docker-rt/) ![Linter](https://github.com/reuteras/docker-rt/workflows/Linter/badge.svg)

[RT](https://www.bestpractical.com/rt/), or Request Tracker, is a issue tracking system. Currently build RT latest (5.0.x) and RT 4.4.x.

## Requirements

In this first build this container makes some assumptions that might not be for everyone. The container is only built to use Postgresql. You also have to use SSL/TLS and have a directory with the following files shared with the container at startup:

* RT_SiteConfig.pm
* server-chain.pem
* server.pem

## Usage

To run docker-rt (change to <full path> to the location of the files specified above):

        docker run -ti -p 443:443 -e RT_HOSTNAME=rt.example.com -e RT_RELAYHOST=mail.example.com -v /<full path>/docker-rt/files:/data --name rt -d reuteras/docker-rt

* `-e RT_HOSTNAME=<RT server hostname>`
* `-e RT_RELAYHOST=<Postfix relay host>`

## Install

In my environment I still use a vm to run Postgresql. Because of that I haven't scripted any default setup to automatically use a linked database container.

## TODO

Lots of things.

* Solution for adding plugins.

