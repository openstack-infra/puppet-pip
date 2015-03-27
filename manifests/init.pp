# Class: pip
#
class pip (
  $index_url = 'https://pypi.python.org/simple',
  $trusted_hosts = []
) {
  include pip::params
  validate_array($trusted_hosts)

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
