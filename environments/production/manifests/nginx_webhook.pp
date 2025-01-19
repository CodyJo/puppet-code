# Install Nginx
package { 'nginx':
  ensure => installed,
}

# Ensure Nginx service is running
service { 'nginx':
  ensure     => running,
  enable     => true,
  subscribe  => File['/etc/nginx/conf.d/github-webhook.conf'],
}

# Nginx configuration for GitHub webhook
file { '/etc/nginx/conf.d/github-webhook.conf':
  ensure  => file,
  content => template('nginx/github-webhook.erb'),
  notify  => Service['nginx'],
}

# Create a directory for log files
file { '/var/log/github-webhook':
  ensure => directory,
  owner  => 'nginx',
  group  => 'nginx',
  mode   => '0755',
}

# Ensure FastCGI wrapper for executing scripts
package { 'fcgiwrap':
  ensure => installed,
}

service { 'fcgiwrap':
  ensure    => running,
  enable    => true,
  hasstatus => true,
  require   => Package['fcgiwrap'],
}

# Script for webhook handling
file { '/usr/local/bin/github-webhook.sh':
  ensure  => file,
  content => template('nginx/github-webhook.sh.erb'),
  mode    => '0755',
}
