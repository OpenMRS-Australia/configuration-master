class appserver {
  include newrelic
  include jdk
  include mysql
  include openmrs
  include tomcat
}
include appserver
