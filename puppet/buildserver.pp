class buildserver {
  include jdk
  include go::server
  include go::agent
}

include buildserver
