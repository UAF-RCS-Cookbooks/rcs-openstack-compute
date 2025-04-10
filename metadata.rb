name             'rcs-openstack-compute'
maintainer       'UAF RCS'
maintainer_email 'chef@rcs.alaska.edu'
license          'Apache-2.0'
description      'The OpenStack Compute service Nova.'
version          '20.0.7'

chef_version '>= 16.0'

%w(ubuntu redhat centos).each do |os|
  supports os
end

depends 'apache2'
depends 'rcs-openstack-common'
depends 'rcs-openstack-identity'
depends 'rcs-openstack-image'
depends 'rcs-openstack-network'
depends 'rcs-openstackclient'
