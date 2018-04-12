# OpenStack PIP Module

## Overview

Configures PIP.

## Usage

To use the module, create a package with the `openstack_pip` provider.

You can optionally pass a `virtualenv` path in `package_settings` to
install the package within a given virtualenv

```
include ::pip

package { 'tox':
  ensure => 'latest',
  provider => openstack_pip,
  require => Class[pip],
  package_settings  => {'virtualenv' => '/path/to/virtualenv/bin'},
}
```
