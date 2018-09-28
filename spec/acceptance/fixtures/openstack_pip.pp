include pip

$packages = [
  'shade',
  'jeepyb',
]
package { $packages:
  ensure   => latest,
  provider => openstack_pip,
  require  => Class['pip'],
}
