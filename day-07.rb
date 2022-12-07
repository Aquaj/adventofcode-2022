require_relative 'common'

class Day7 < AdventDay
  EXPECTED_RESULTS = { 1 => 95437, 2 => 24933642 }

  STORAGE_SIZE = 70_000_000
  NEEDED_SPACE = 30_000_000

  SMALL_FOLDER_SIZE = 100_000

  ROOT_PATH = []

  def first_part
    tree = filesystem[:tree]
    sizes = compute_sizes('/', tree)
    dirs = directories(tree)

    sizes.
      select { |path, _size| dirs.include?(path) }.
      select { |_path, size| size <= SMALL_FOLDER_SIZE }.
      sum { |_path, size| size }
  end

  def second_part
    tree = filesystem[:tree]
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

  def filesystem
    input.each_with_object({ curdir: [], tree: {} }) do |cmd, state|
      send(:"parse_#{cmd[:command]}", cmd[:arg], cmd[:output], state)
    end
  end

  def parse_ls(_arg, output, state)
    currdir = state[:curdir].reduce(state[:tree]) do |tree, dir| # Initializing + traversal
      tree[dir] ||= {}
    end

    output.each_with_object(currdir) do |entry, currdir_contents|
      case entry
      when /^dir .*$/
        _, dirname = entry.split
        currdir_contents[dirname] ||= {}
      else
        size, filename = entry.split
        currdir_contents[filename] = size.to_i
      end
    end
  end

  def parse_cd(arg, _output, state)
    case arg
    when '/'
      state[:curdir] = ROOT_PATH
    when '..'
      state[:curdir].pop
    else
      state[:curdir] << arg
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
