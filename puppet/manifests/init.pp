# Init puppet provisioner for Magento installation

Exec {
    path => [
        '/usr/local/bin',
        '/opt/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/bin',
        '/sbin'
    ],
    logoutput => false,
}

# The server
class { "server":
    hostname => "${hostname}"
}

# Apache
class { "apache":
    server_name     => "${server::hostname}",
    document_root   => "${document_root}",
    logs_dir        => "${logs_dir}"
}

# MySQL
class { "mysql":
    root_password   => "${db_root_password}",
    db_name         => "${db_name}",
    db_user         => "${db_user}",
    db_password     => "${db_password}",
    db_name_tests   => "${db_name_tests}",
}

# PHP
class { "php":
}


# Includes
include server
include apache
include mysql
include php
include mailcatcher
include git
include tools

#################################################
# Ruby
#################################################

$as_vagrant   = 'sudo -u vagrant -H bash -l -c'
$home         = '/home/vagrant'

class rvm {

  exec { 'install_rvm':
    command => "${as_vagrant} 'curl -L https://get.rvm.io | bash -s stable'",
    creates => "${home}/.rvm/bin/rvm",
    require => Package['curl']
  }

  exec { 'install_ruby':
    # We run the rvm executable directly because the shell function assumes an
    # interactive environment, in particular to display messages or ask questions.
    # The rvm executable is more suitable for automated installs.
    #
    # Thanks to @mpapis for this tip.
    command => "${as_vagrant} '${home}/.rvm/bin/rvm install 2.0.0 --latest-binary --autolibs=enabled && rvm --fuzzy alias create default 2.0.0'",
    creates => "${home}/.rvm/bin/ruby",
    require => Exec['install_rvm']
  }

  exec { "${as_vagrant} 'gem install bundler --no-rdoc --no-ri'":
    creates => "${home}/.rvm/bin/bundle",
    require => Exec['install_ruby']
  }

  exec { "${as_vagrant} 'gem install --version 2.15.4 capistrano'":
    require => Exec['install_ruby']
  }

  exec { "${as_vagrant} 'gem install --version 0.0.6 magentify'":
    require => Exec['install_ruby']
  }
  
  exec { "${as_vagrant} 'gem install compass'":
    require => Exec['install_ruby']
  }

}

include rvm
