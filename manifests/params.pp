# Class: pip::params
#
# This class holds parameters that need to be
# accessed by other classes.
class pip::params {
  $get_pip_location = 'https://bootstrap.pypa.io/get-pip.py'

  case $::osfamily {
    'RedHat': {
      $python_devel_package  = 'python-devel'
      $python3_devel_package = 'python3-devel'
      $python3_pip_package   = 'python3-pip'
      $get_pip_path          = '/bin/pip'
    }
    'Debian': {
      $python_devel_package  = 'python-all-dev'
      $python3_devel_package = 'python3-all-dev'
      $python3_pip_package   = 'python3-pip'
      $get_pip_path          = '/usr/local/bin/pip'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'pip' module only supports osfamily Debian or RedHat.")
    }
  }
}
