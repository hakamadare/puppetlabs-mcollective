# Class: mcollective::client::base
#
#   This class installs the MCollective client component for your nodes.
#
# Parameters:
#
#  [*version*]            - The version of the MCollective package(s) to
#                             be installed.
#  [*config*]             - The content of the MCollective client configuration
#                             file.
#  [*config_file*]        - The full path to the MCollective client
#                             configuration file.
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::client::base(
  $version,
  $config,
  $manage_packages,
  $config_file
) inherits mcollective::params {

  anchor { "mcollective::client::base::begin": }
  anchor { "mcollective::client::base::end": }

  if $manage_packages {
    class { 'mcollective::client::package':
      version => $version,
      require => Anchor['mcollective::client::base::begin'],
      before  => Class['mcollective::client::config']
    }

    if ( $version != 'present' and $version != 'latest' ) {
      File {
        ensure  => 'link',
        require => Class['mcollective::client::package']
      }

      case versioncmp( $version, '2.2.0' ) {
        '-1': {
          file {
            '/usr/bin/mco':
              target => '/usr/sbin/mco'
          }
        }
        default: {
          file {
            '/usr/sbin/mco':
              target => '/usr/bin/mco'
          }
        }
      }
    }

  }
  class { 'mcollective::client::config':
    config      => $config,
    config_file => $config_file,
    require     => Anchor['mcollective::client::base::begin'],
    before      => Anchor['mcollective::client::base::end'],
  }

}

