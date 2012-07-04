class tomcat {
  package { "tomcat6":
    ensure => "installed",
    provider => "yum",
  }

  file { "/var/lib/tomcat6/webapps":
    ensure => "directory",
    owner => "tomcat",
    group => "tomcat",
    require => Package["tomcat6"],
  }

  service { "tomcat6":
    ensure => "running",
    require => Package["tomcat6"],
  }
}
