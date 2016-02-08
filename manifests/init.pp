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
# Copyright 2016 Your name here, unless otherwise noted.
#
class celery (
  $app,
  $app_dir,
  $import_py              = undef,
  $user                   = 'celery',
  $group                  = 'celery',
  $create_user            = false,
  $queues                 = undef,
  $routes                 = undef,
  $workers                = 'celery',
  $celery_opts            = undef,
  $backend                = 'redis://localhost',
  $broker                 = 'ampq://guest@localhost//',
  $broker_api             = 'http://guest:guest@localhost:15672/api/',
  Integer[0] $time_limit  = 300,
  Integer[0] $concurrency = 8,
  $flower                 = false,
  $log_level              = 'INFO',
  $envfile                = '/etc/celery/celery.conf',
  $celery_version         = '3.1.19',
  $flower_version         = latest,
  $redis_support          = true
) {

  $runfile = "${app_dir}/${app}.py"

  unless $::lsbdistcodename => 'jessie' {
    fail( join(
      'Only Debian jessie is supported for this module at this time,',
      "but you're running ${::lsbdistcodename}", ' ')
    )
  }

  python::pip { 'celery':
    ensure => $celery_version
  }

  if $redis_support {
    python::pip { 'redis',
      ensure => present
    }
  }

  if $flower {
    python::pip { 'flower':
      ensure => $flower_version
    }
  }

  if $import_py {
    $import_n = join($import_py.map |$i| { "import ${i}" }, "\n")
  }

  concat { $runfile:
    owner  => $user,
    group  => $group,
    mode   => '0444',
    notify => Service['celery']
  }

  concat::fragment { "${app}_base":
    target  => $runfile,
    content => template('modules/celery/tasks_base.erb'),
    order   => 0
  }

  file {
    default:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0400'
      ;
    "/home/${user}/celeryapp":
      ensure => directory,
      owner  => $user,
      group  => $group,
      ;
    '/lib/systemd/system/celery.service':
      content => template('modules/celery/celery_service.erb')
      ;
    '/lib/systemd/system/flower.service':
      content => template('modules/celery/flower_service.erb')
      ;
    '/etc/celery':
      ensure => directory,
      mode   => '0444'
      ;
    $envfile:
      content => template('modules/celery/celery_conf.erb'),
  }

  service { 'celery':
    ensure => 'running'
  }
}
