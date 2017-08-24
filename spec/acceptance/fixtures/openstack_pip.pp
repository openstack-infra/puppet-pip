include pip

$packages = [
  'shade',
]
package { $packages:
  ensure   => latest,
  provider => openstack_pip,
  require  => Class['pip'],
}
