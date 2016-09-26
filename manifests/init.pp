# Class: celery
# ===========================
#
# Manage Celery workers and tasks
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'celery':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Matt Kirby <matt.kirby@me.com>
#
# Copyright
# ---------
#
# Copyright 2016 Puppet Labs, Inc., unless otherwise noted.

class celery (
  $app,
  $app_dir,
  $app_conf               = undef,
  $import_py              = undef,
  $user                   = 'celery',
  $group                  = 'celery',
  $create_user            = false,
  $queues                 = undef,
  $routes                 = undef,
  $workers                = 'celery',
  $celery_opts            = undef,
  $backend                = 'redis://localhost',
  $broker                 = 'amqp://guest@localhost//',
  $broker_api             = 'http://guest:guest@localhost:15672/api/',
  Integer[0] $time_limit  = 300,
  Integer[0] $concurrency = 8,
  $flower                 = false,
  $log_level              = 'INFO',
  $envfile                = '/etc/celery/celery.conf',
  $celery_version         = '3.1.19',
  $flower_version         = latest,
  $redis_support          = true,
  $service_path           = $celery::params::service_path,
  $service_config         = $celery::params::service_config,
  $service_config_source  = undef,
  $service_template       = $celery::params::service_template,
) inherits celery::params{

  $runfile = "${app_dir}/${app}.py"

  unless $::lsbdistcodename =~ 'jessie|trusty' {
    fail( join(
      'Only Debian jessie is supported for this module at this time,',
      "but you're running ${::lsbdistcodename}", ' ')
    )
  }

  python::pip { 'celery':
    ensure => $celery_version,
  }

  if $redis_support {
    python::pip { 'redis':
      ensure => present,
    }
  }

  if $flower {
    python::pip { 'flower':
      ensure => $flower_version,
    }
  }

  if $import_py {
    $import_n = join($import_py.map |$i| { "import ${i}\n" }, '')
  }

  if $app_conf {
    file { $app_conf:
      ensure => present,
      owner  => $user,
      group  => $group,
      path   => "${app_dir}/${app_conf}",
    }
  } else {
    file {
      default:
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644'
        ;
      $runfile:
        owner   => $user,
        group   => $group,
        content => template('celery/tasks_base.erb')
        ;
      "${app_dir}/celery_instance.py":
        owner   => $user,
        group   => $group,
        content => template('celery/celery_instance.erb'),
    }
  }

  file {
    default:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644'
      ;
    $app_dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0400'
      ;
    "/home/${user}/run":
      ensure => directory,
      owner  => $user,
      group  => $group
      ;
    "${service_path}/${service_config}":
      content => template($service_template),
      source  => $service_config_source,
      ;
    "${service_path}/flower.service":
      content => template('celery/flower_service.erb')
      ;
    '/etc/celery':
      ensure => directory,
      mode   => '0444'
      ;
    $envfile:
      content => template('celery/celery_conf.erb'),
      mode    => '0400',
  }

  service { 'celery':
    ensure => 'running',
    enable => true,
    name   => 'celery.service',
  }
}
