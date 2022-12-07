require_relative 'common'

class Day7 < AdventDay
  EXPECTED_RESULTS = { 1 => 95437, 2 => 24933642 }

  STORAGE_SIZE = 70_000_000
  NEEDED_SPACE = 30_000_000

  SMALL_FOLDER_SIZE = 100_000

  def first_part
    tree = filesystem.tree
    sizes = compute_sizes('/', tree)
    dirs = directories(tree)

    sizes.
      select { |path, _size| dirs.include?(path) }.
      select { |_path, size| size <= SMALL_FOLDER_SIZE }.
      sum { |_path, size| size }
  end

  def second_part
    tree = filesystem.tree
    sizes = compute_sizes('/', tree)
    dirs = directories(tree)

    remaining_space = STORAGE_SIZE - sizes[ROOT_PATH]

    dir, freeable_space = sizes.
      select { |path, _size| dirs.include?(path) }.
      sort_by { |_dir, size| size }.
      find { |dir, freeable| remaining_space + freeable >= NEEDED_SPACE }
    freeable_space
  end

  private

  def directories(tree, currpath = ROOT_PATH)
    dir_paths = tree.select { |entry, content| content.is_a? Hash }.to_h
    subdir_paths = dir_paths.flat_map { |path, subtree| directories(subtree, path) }

    [currpath, *subdir_paths.map { |path| [*currpath, *path] }]
  end

  def compute_sizes(treetop, contents, size_list = {}, currpath = ROOT_PATH)
    return size_list.tap { |sizes| sizes[currpath] = contents } unless contents.is_a? Hash

    # Compute entry sizes
    contents.each { |entry, value| compute_sizes(entry, value, size_list, [*currpath, entry]) }
    # Current path size == sum of all entries
    size_list[currpath] = contents.sum { |entry, _| size_list[[*currpath,  entry]] }

    size_list
  end

  class FileSystemParser
    ROOT_PATH = []

    attr_reader :current_path, :tree

    def initialize
      @current_path = []
      @tree = {}
    end

    def path_contents(path)
      path.reduce(@tree) { |tree, dir| tree[dir] ||= {} }
    end

    def parse_ls(_arg, output)
      output.each_with_object(path_contents(@current_path)) do |entry, contents|
        case entry
        when /^dir .*$/
          _, dirname = entry.split
          contents[dirname] ||= {}
        else
          size, filename = entry.split
          contents[filename] = size.to_i
        end
      end
    end

    def parse_cd(arg, _output)
      case arg
      when '/'
        @current_path = ROOT_PATH
      when '..'
        @current_path.pop
      else
        @current_path << arg
      end
    end
  end

  ROOT_PATH = FileSystemParser::ROOT_PATH

  def filesystem
    input.each_with_object(FileSystemParser.new) do |cmd, fs|
      fs.send(:"parse_#{cmd[:command]}", cmd[:arg], cmd[:output])
    end
  end


  def convert_data(data)
    super.each_with_object([]) do |line, output|
      if cmd = line.match(/\$ (.*)/)&.captures&.unwrap
        exe, *arg = cmd.split
        arg = arg.any? ? arg.join(' ') : nil
        output << { command: exe.to_sym, arg: arg,  output: [] }
      else
        output.last[:output] << line
      end
    end
  end
end

Day7.solve
