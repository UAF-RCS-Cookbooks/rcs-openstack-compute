name             'rcs-openstack-compute'
maintainer       'UAF RCS'
maintainer_email 'chef@rcs.alaska.edu'
license          'Apache-2.0'
description      'The OpenStack Compute service Nova.'
version          '20.0.6'

chef_version '>= 16.0'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'apache2', '~> 8.6'
depends 'rcs-openstack-common', '>= 20.0.0'
depends 'rcs-openstack-identity', '>= 20.0.0'
depends 'rcs-openstack-image', '>= 20.0.0'
depends 'rcs-openstack-network', '>= 20.0.0'
depends 'rcs-openstackclient', '>= 20.0.0'
