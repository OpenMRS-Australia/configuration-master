require "spec_helper"
require "lib/go/artifact_finder"
require "json"

describe "Artifact Finder" do
  before :each do
    @json = JSON.parse(File.read(File.dirname(__FILE__) + "/go_artifacts.json"))
  end

  it "should successfully find the location of the artifact" do
    ArtifactFinder.new(@json).uri("cruise-output").should == "http://ec2-50-112-42-202.us-west-2.compute.amazonaws.com:8153/go/files/CPM-Module/14/Package/1/Package/cruise-output/console.log"
  end

  it "should raise an appropriate error message if it can't find the artifact" do
    expect { ArtifactFinder.new(@json).uri("nonexistant") }.should raise_error(RuntimeError, /Could not find an artifact for/)
  end

  it "should find an artifact in a nested directory" do
    ArtifactFinder.new(@json).uri("omod/target").should == "http://ec2-50-112-42-202.us-west-2.compute.amazonaws.com:8153/go/files/CPM-Module/14/Package/1/Package/omod/target/cpm-1.0-SNAPSHOT-SHA1-389e41c.omod"

    ArtifactFinder.new(@json).uri("omod/target/foobar").should == "http://stuffs.xml"
  end
end