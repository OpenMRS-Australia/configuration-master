class tomcat {
  package { "tomcat6":
    ensure => "installed",
    provider => "yum",
  }

  service { "tomcat6":
    ensure => "running",
    require => Package["tomcat6"],
  }
}
