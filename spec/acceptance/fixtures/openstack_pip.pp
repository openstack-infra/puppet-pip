include pip

$packages = [
  'shade',
  'diskimage-builder',
]
package { $packages:
  ensure   => latest,
  provider => openstack_pip,
  require  => Class['pip'],
}
