# Class: pip
#
class pip (
  $index_url         = 'https://pypi.python.org/simple',
  $manage_pip_conf   = false,
  $optional_settings = {},
  $trusted_hosts     = [],
) {
  include ::pip::params
  validate_array($trusted_hosts)

  package { $::pip::params::python_devel_package:
    ensure => present,
  }

  exec { 'download-pip':
    command => "/usr/bin/curl ${::pip::params::get_pip_location} | /usr/bin/python",
    creates => $::pip::params::get_pip_path,
  }

  if $manage_pip_conf {
    file { '/etc/pip.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('pip/pip.conf.erb'),
      replace => true,
    }
  }
}
