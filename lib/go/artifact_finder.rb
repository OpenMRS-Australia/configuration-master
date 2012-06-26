class ArtifactFinder
  attr_reader :json

  def initialize(json)
    @json = json
  end

  def uri(path)
    begin
      directories = path.split('/')

      directories.reduce(json){ |tree, directory| find_element(tree, directory) }.first["url"]
    rescue => e
      raise "Could not find an artifact for #{path} => #{e.message}"
    end
  end

  private
  def find_element(tree, path)
    tree.find{ |element| element["name"].eql? path }["files"]
  end
end

