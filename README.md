# celery

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with celery](#setup)
    * [What celery affects](#what-celery-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with celery](#beginning-with-celery)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Provide mechanism to deploy Celery workers and tasks.

This module provides the capability to specify Celery workers and queues along with
tasks to be run by Celery.

## Setup

### What celery affects **OPTIONAL**

This service manages the Celery application and provides a mechanism for running
Celery as a service.

### Setup Requirements **OPTIONAL**

You will need a RabbitMQ server to provide a queue for Celery. If you would like to
store results then you will want to configure a Redis server and specify the backend
to Celery.

### Beginning with celery

The easiest way to start with Celery is to deploy a all-in-one node. If you look
in examples you will see an example of deploying Celery along with Redis and RabbitMQ
on a single node. This is a reasonable way to setup a dev environment or to start using
Celery. If you plan to deploy multiple workers then it is a good practice to separate
your queue from any of the workers.

## Usage

TODO

## Reference

TODO

## Limitations

This module is designed for use with Debian 8, jessie. Celery works on a wide range
of platforms. This iteration of the module does not attempt to support this wide range.
Instead, the scope of this module is to support Celery well on jessie. Pull requests are
welcome if you would like to add additional OS support.

## Development

Pull requests are welcome. Please feel free to improve this module and add support for
additional operating systems.
