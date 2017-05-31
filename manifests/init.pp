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

  if $::operatingsystem != 'CentOS' {
      exec { 'download-pip3':
        command => "/usr/bin/curl ${::pip::params::get_pip_location} | /usr/bin/python3 - -U --force-reinstall",
        creates => $::pip::params::get_pip3_path,
        before  => Exec['download-pip'],
        notify  => Exec[$::pip::params::get_pip_path]
    }
  }

  exec { 'download-pip':
    command => "/usr/bin/curl ${::pip::params::get_pip_location} | /usr/bin/python - -U --force-reinstall",
    creates => $::pip::params::get_pip2_path,
    notify  => Exec[$::pip::params::get_pip_path]
  }

  # NOTE(pabelanger): Default to pip2 for backwards compat
  exec { $::pip::params::get_pip_path:
    command     => "ln -sf ${::pip::params::get_pip_path} ${::pip::params::get_pip2_path}",
    path        => '/usr/bin:/bin/',
    refreshonly => true,
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
