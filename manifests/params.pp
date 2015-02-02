# Class: pip::params
#
# This class holds parameters that need to be
# accessed by other classes.
class pip::params {
  case $::osfamily {
    'RedHat': {
      $python_devel_package = 'python-devel'
    }
    'Debian': {
      $python_devel_package  = 'python-all-dev'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'pip' module only supports osfamily Debian or RedHat.")
    }
  }
}
