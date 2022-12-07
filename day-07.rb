require_relative 'common'

class Day7 < AdventDay
  EXPECTED_RESULTS = { 1 => 95437, 2 => nil }

  def first_part
    tree = filesystem[:tree]
    sizes = compute_sizes('/', tree)
    dirs = directories(tree)
    sizes.
      select { |path, _size| dirs.include?(path) }.
      select { |_path, size| size <= 100_000 }.
      sum { |_path, size| size }
  end

  def second_part
  end

  private

  def directories(tree)
    dir_only_tree = tree.select { |entry, content| content.is_a? Hash }.to_h
    (dir_only_tree.keys.map { |k| [k] } + dir_only_tree.flat_map { |path, subtree| directories(subtree).map { |dir| [*path, dir].flatten }})
  end

  def filesystem
    input.each_with_object({ curdir: [], tree: {} }) do |cmd, state|
      case cmd[:command]
      when :cd
        case cmd[:arg]
        when '/'
          state[:curdir] = []
        when '..'
          state[:curdir] = state[:curdir][0...-1]
        else
          state[:curdir] << cmd[:arg]
        end
      when :ls
        curdir = state[:curdir].reduce(state[:tree]) do |tree, dir|
          tree[dir] ||= {}
        end
        cmd[:output].each_with_object(curdir) do |file, dir|
          case file
          when /^dir .*$/
            _, dirname = file.split
            dir[dirname] ||= {}
          else
            size, filename = file.split
            dir[filename] = size.to_i
          end
        end
      end
    end
  end

  def compute_sizes(treetop, contents, size_list = {}, currpath = [])
    return size_list.tap { |sizes| sizes[currpath] = contents } unless contents.is_a? Hash

    contents.each do |entry, value|
      compute_sizes(entry, value, size_list, [*currpath, entry])
    end
    size_list[currpath] = contents.sum { |entry, _| size_list[[*currpath,  entry]] }
    size_list
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
