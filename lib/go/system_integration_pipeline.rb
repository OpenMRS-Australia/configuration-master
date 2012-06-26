require "go/pipeline"

module Go
  class SystemIntegrationPipeline < Pipeline
    def initialize
      super
    end

    def cpm_module_artifact
      artifact_location "CPM-Module", "package", "target"
    end

    def configuration_master_artifact
      artifact_location "CONFIGURATION", "package", "build"
    end
  end
end
