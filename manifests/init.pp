# Class: pip
#
class pip {
  include pip::params
  validate_array($::pip::params::trusted_hosts)

  package { $::pip::params::python_devel_package:
    ensure => present,
  }

  if ! defined(File['/etc/pip.conf']) {
    file { '/etc/pip.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('pip/pip.conf.erb'),
      replace => true,
    }
  }
}
