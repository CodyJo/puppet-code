class nginx (
  String $server_name = 'default',
  String $repo_dir = '/etc/puppetlabs/code/environments/production',
) {

  # Install Nginx package
  package { 'nginx':
    ensure => installed,
  }

  # Ensure Nginx service is running
  service { 'nginx':
    ensure     => running,
    enable     => true,
    subscribe  => File['/etc/nginx/conf.d/github-webhook.conf'],
  }

  # Nginx configuration file for the GitHub webhook
  file { '/etc/nginx/conf.d/github-webhook.conf':
    ensure  => file,
    content => template('nginx/github-webhook.erb'),
    notify  => Service['nginx'],
  }

  # Create a directory for webhook logs
  file { '/var/log/github-webhook':
    ensure => directory,
    owner  => 'nginx',
    group  => 'nginx',
    mode   => '0755',
  }

  # Install the FastCGI wrapper package
  package { 'fcgiwrap':
    ensure => installed,
  }

  # Ensure the FastCGI service is running
  service { 'fcgiwrap':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package['fcgiwrap'],
  }

  # Webhook script to handle incoming GitHub webhook requests
  file { '/usr/local/bin/github-webhook.sh':
    ensure  => file,
    content => template('nginx/github-webhook.sh.erb'),
    mode    => '0755',
  }
}
