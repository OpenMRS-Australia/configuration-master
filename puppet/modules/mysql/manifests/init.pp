class mysql {
  package { "mysql-server":
    ensure => "installed",
    provider => "yum",
  }

  service { "mysqld":
    ensure => "running",
    require => Package["mysql-server"],
  }

  exec { "set_mysql_password":
    command => "/usr/bin/mysqladmin -u root password 'openmrs' && touch /var/log/mysql-server-password-set",
    require => Service["mysqld"],
    creates => "/var/log/mysql-server-password-set",
  }
}
