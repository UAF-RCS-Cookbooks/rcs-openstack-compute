
# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['compute']['custom_template_banner'] = '
# This file is automatically generated by Chef
# Any changes will be overwritten
'

# Set dbsync command timeout value
default['openstack']['compute']['dbsync_timeout'] = 3600

# Role to assign for the nova service user
default['openstack']['compute']['service_role'] = 'admin'

# Used to set correct permissions for directories and files
default['openstack']['compute']['user'] = 'nova'
default['openstack']['compute']['group'] = 'nova'

# If set to 'spice' or 'vnc' the cookbook will attempt to automatically
# enable the right type; any other type will require appropriate attributes
# to be set by the user.
default['openstack']['compute']['console_type'] = 'vnc'

# Logging stuff
default['openstack']['compute']['syslog']['use'] = false
default['openstack']['compute']['syslog']['facility'] = 'LOG_LOCAL1'
default['openstack']['compute']['syslog']['config_facility'] = 'local1'

# rootwrap.conf
default['openstack']['compute']['rootwrap']['filters_path'] = '/etc/nova/rootwrap.d,/usr/share/nova/rootwrap'
default['openstack']['compute']['rootwrap']['exec_dirs'] = '/sbin,/usr/sbin,/bin,/usr/bin'
default['openstack']['compute']['rootwrap']['use_syslog'] = 'False'
default['openstack']['compute']['rootwrap']['syslog_log_facility'] = 'syslog'
default['openstack']['compute']['rootwrap']['syslog_log_level'] = 'ERROR'

# SSL settings
%w(api metadata).each do |service|
  default['openstack']['compute'][service]['ssl']['enabled'] = false
  default['openstack']['compute'][service]['ssl']['certfile'] = ''
  default['openstack']['compute'][service]['ssl']['chainfile'] = ''
  default['openstack']['compute'][service]['ssl']['keyfile'] = ''
  default['openstack']['compute'][service]['ssl']['ca_certs_path'] = ''
  default['openstack']['compute'][service]['ssl']['cert_required'] = false
  default['openstack']['compute'][service]['ssl']['protocol'] = ''
  default['openstack']['compute'][service]['ssl']['ciphers'] = ''
end

# Work around upstream issue with running the api services under wsgi
# https://docs.openstack.org/releasenotes/nova/stein.html#known-issues
default['openstack']['compute']['api']['threads'] = 1
default['openstack']['compute']['api']['processes'] = 6
default['openstack']['compute']['metadata']['threads'] = 1
default['openstack']['compute']['metadata']['processes'] = 2

# Platform specific settings
case node['platform_family']
when 'rhel' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['compute']['platform'] = {
    'api_os_compute_packages' => ['openstack-nova-api'],
    'api_os_compute_service' => 'openstack-nova-api',
    'memcache_python_packages' =>
      if node['platform_version'].to_i >= 8
        ['python3-memcached']
      else
        ['python-memcached']
      end,
    'compute_api_metadata_packages' => ['openstack-nova-api'],
    'compute_api_metadata_service' => 'openstack-nova-metadata-api',
    'compute_compute_packages' => ['openstack-nova-compute'],
    'qemu_compute_packages' => [],
    'kvm_compute_packages' => [],
    'compute_compute_service' => 'openstack-nova-compute',
    'compute_scheduler_packages' => ['openstack-nova-scheduler'],
    'compute_scheduler_service' => 'openstack-nova-scheduler',
    'compute_conductor_packages' => ['openstack-nova-conductor'],
    'compute_conductor_service' => 'openstack-nova-conductor',
    'compute_vncproxy_packages' => ['openstack-nova-novncproxy'],
    'compute_vncproxy_service' => 'openstack-nova-novncproxy',
    'compute_spiceproxy_packages' => %w(openstack-nova-spicehtml5proxy spice-html5),
    'compute_spiceproxy_service' => 'openstack-nova-spicehtml5proxy',
    'compute_serialproxy_packages' => ['openstack-nova-serialproxy'],
    'compute_serialproxy_service' => 'openstack-nova-serialproxy',
    'libvirt_packages' =>
      if node['platform_version'].to_i >= 8
        %w(libvirt device-mapper python3-libguestfs)
      else
        %w(libvirt device-mapper python-libguestfs)
      end,
    'libvirt_service' => 'libvirtd',
    'dbus_service' => 'dbus-broker',
    'compute_cert_packages' => ['openstack-nova-cert'],
    'compute_cert_service' => 'openstack-nova-cert',
    'mysql_service' => 'mysqld',
    'common_packages' => %w(openstack-nova-common),
    'iscsi_helper' => 'ietadm',
    'volume_packages' => %w(sysfsutils sg3_utils device-mapper-multipath),
    'package_overrides' => '',
  }
when 'debian'
  default['openstack']['compute']['platform'] = {
    'api_os_compute_packages' => %w(python3-nova nova-api),
    'api_os_compute_service' => 'nova-api',
    'memcache_python_packages' => ['python3-memcache'],
    'compute_api_metadata_packages' => %w(python3-nova nova-api-metadata),
    'compute_api_metadata_service' => 'nova-api-metadata',
    'compute_compute_packages' => %w(python3-nova nova-compute),
    'qemu_compute_packages' => %w(python3-nova nova-compute-qemu),
    'kvm_compute_packages' => %w(python3-nova nova-compute-kvm),
    'compute_compute_service' => 'nova-compute',
    'compute_scheduler_packages' => %w(python3-nova nova-scheduler),
    'compute_scheduler_service' => 'nova-scheduler',
    'compute_conductor_packages' => %w(python3-nova nova-conductor),
    'compute_conductor_service' => 'nova-conductor',
    # Websockify is needed due to https://bugs.launchpad.net/ubuntu/+source/nova/+bug/1076442
    'compute_vncproxy_packages' =>
      if platform?('ubuntu')
        %w(novnc websockify python3-nova nova-novncproxy)
      else
        %w(nova-consoleproxy)
      end,
    'compute_vncproxy_service' => 'nova-novncproxy',
    'compute_spiceproxy_packages' =>
      if platform?('ubuntu')
        %w(nova-spiceproxy spice-html5)
      else
        %w(nova-consoleproxy)
      end,
    'compute_spiceproxy_service' => platform?('ubuntu') ? 'nova-spiceproxy' : 'nova-spicehtml5proxy',
    'compute_serialproxy_packages' => %w(python3-nova nova-serialproxy),
    'compute_serialproxy_service' => 'nova-serialproxy',
    'libvirt_packages' => %w(libvirt-bin python3-guestfs),
    'libvirt_service' => 'libvirtd',
    'dbus_service' => 'dbus',
    'mysql_service' => 'mysql',
    'common_packages' => %w(nova-common python3-nova),
    'iscsi_helper' => 'tgtadm',
    'volume_packages' => %w(sysfsutils sg3-utils multipath-tools),
    'package_overrides' => '',
  }
end

# Array of options for `api-paste.ini` (e.g. ['option1=value1', ...])
default['openstack']['compute']['misc_paste'] = nil

# ****************** OpenStack Compute Endpoints ******************************

# The OpenStack Compute (Nova) endpoints
%w(
  compute-api
  compute-metadata-api
  compute-novnc
  compute-vnc
  compute-spicehtml5
  compute-spice
).each do |service|
  default['openstack']['bind_service']['all'][service]['host'] = '127.0.0.1'
  %w(public internal).each do |type|
    default['openstack']['endpoints'][type][service]['host'] = '127.0.0.1'
    default['openstack']['endpoints'][type][service]['scheme'] = 'http'
  end
end
%w(public internal).each do |type|
  # The OpenStack Compute (Nova) Native API endpoint
  default['openstack']['endpoints'][type]['compute-api']['port'] = '8774'
  default['openstack']['endpoints'][type]['compute-api']['path'] = '/v2.1/%(tenant_id)s'
  # The OpenStack Compute (Nova) novnc endpoint
  default['openstack']['endpoints'][type]['compute-novnc']['port'] = '6080'
  default['openstack']['endpoints'][type]['compute-novnc']['path'] = '/vnc_auto.html'
  # The OpenStack Compute (Nova) spicehtml5 endpoint
  default['openstack']['endpoints'][type]['compute-spicehtml5']['port'] = '6082'
  default['openstack']['endpoints'][type]['compute-spicehtml5']['path'] = '/spice_auto.html'
  # The OpenStack Compute (Nova) metadata API endpoint
  default['openstack']['endpoints'][type]['compute-metadata-api']['port'] = '8775'
  default['openstack']['endpoints'][type]['compute-metadata-api']['path'] = ''
  # The OpenStack Compute (Nova) serial proxy endpoint
  default['openstack']['endpoints'][type]['compute-serial-proxy']['scheme'] = 'ws'
  default['openstack']['endpoints'][type]['compute-serial-proxy']['port'] = '6083'
  default['openstack']['endpoints'][type]['compute-serial-proxy']['path'] = '/'
  default['openstack']['endpoints'][type]['compute-serial-proxy']['host'] = '127.0.0.1'
end
default['openstack']['bind_service']['all']['compute-serial-proxy']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-vnc-proxy']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-spice-proxy']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-serial-console']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-vnc']['port'] = '6081'
default['openstack']['bind_service']['all']['compute-spice']['port'] = '6081'
default['openstack']['bind_service']['all']['compute-serial-proxy']['port'] = '6081'
default['openstack']['bind_service']['all']['compute-novnc']['port'] = '6080'
default['openstack']['bind_service']['all']['compute-spicehtml5']['port'] = '6082'
default['openstack']['bind_service']['all']['compute-metadata-api']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-metadata-api']['port'] = '8775'
default['openstack']['bind_service']['all']['compute-api']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['compute-api']['port'] = '8774'
