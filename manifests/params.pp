# Class: celery::params
#
class celery::params {
  case $::operatingsystem {
    'Ubuntu': {
      $service_template = 'celery/celery_upstart.erb'
      $service_config = 'celery.conf'
      $service_path = '/etc/init'
    }
    'Debian': {
      $service_template = 'celery/celery_service.erb'
      $service_config = 'celery.service'
      $service_path = '/etc/systemd/system'
    }
    default: {
      fail("\"${module_name}\" provides no config for \"${::operatingsystem}\"")
    }
  }
}
