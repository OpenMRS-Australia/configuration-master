define download($uri, $timeout = 300) {
  exec { "download $uri":
    command => "/usr/bin/wget -q '$uri' -O $name",
    creates => $name,
    timeout => $timeout,
  }
}

class openmrs {
  download { "/var/lib/tomcat6/webapps/openmrs.war":
    uri => "http://downloads.sourceforge.net/project/openmrs/releases/OpenMRS_1.9.0/openmrs.war",
    timeout => 900,
    require => Package['tomcat6'],
    notify => Service['tomcat6'],
  }

  file { "/usr/share/tomcat6/.OpenMRS":
    ensure => "directory",
    owner => "tomcat",
    group => "tomcat",
    require => Package["tomcat6"],
  }
}