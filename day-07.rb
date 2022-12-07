require_relative 'common'

class Day7 < AdventDay
  EXPECTED_RESULTS = { 1 => 95437, 2 => 24933642 }

  SMALL_FOLDER_SIZE = 100_000
  def first_part
    filesystem.directories.
      map { |path| filesystem.filesize_for(path) }.
      select { |size| size <= SMALL_FOLDER_SIZE }.
      sum
  end

  NEEDED_SPACE = 30_000_000
  def second_part
    dir, freeable_space = filesystem.directories.
      map { |path| [path, filesystem.filesize_for(path)] }.
      sort_by { |_dir, size| size }.
      find { |dir, freeable| filesystem.remaining_space + freeable >= NEEDED_SPACE }

    freeable_space
  end

  private

  class FileSystem
    ROOT_PATH = [].freeze
    STORAGE_SIZE = 70_000_000

    attr_reader :current_path, :tree, :directories

    def initialize
      @current_path = []
      @tree = {}

      @directories = []
      @filesizes = {}
    end

    module Parsing
      def parse_ls(_arg, output)
        output.each_with_object(path_contents(@current_path)) do |entry, contents|
          case entry
          when /^dir .*$/
            _, dirname = entry.split
            contents[dirname] ||= {}

            @directories << [*@current_path, dirname]
          else
            size, filename = entry.split
            contents[filename] = size.to_i

            register_filesize(filename, size)
          end
        end
      end

      def parse_cd(arg, _output)
        case arg
        when '/'
          @current_path = ROOT_PATH.dup
        when '..'
          @current_path.pop
        else
          @current_path << arg
        end
      end
    end
    include Parsing

    def remaining_space
      STORAGE_SIZE - filesize_for(ROOT_PATH)
    end

    def filesize_for(path)
      @filesizes[path]
    end

    def register_filesize(filename, size)
      paths_containing = [*@current_path, filename].reverse.each_with_object([]) do |path, keys|
        keys.map! { |key| [path, *key] }
        keys << [path]
      end

      [ROOT_PATH, *paths_containing].each do |path|
        @filesizes[path] ||= 0
        @filesizes[path] += size.to_i
      end
    end

    private

    def path_contents(path)
      path.reduce(@tree) { |tree, dir| tree[dir] ||= {} }
    end
  end

  def filesystem
    @filesytem ||= commands.each_with_object(FileSystem.new) do |cmd, fs|
      fs.send(:"parse_#{cmd[:exe]}", cmd[:arg], cmd[:output])
    end
  end


  def convert_data(data)
    super.each_with_object([]) do |line, output|
      if cmd = line.match(/\$ (.*)/)&.captures&.unwrap
        exe, *arg = cmd.split
        arg = arg.any? ? arg.join(' ') : nil
        output << { exe: exe.to_sym, arg: arg,  output: [] }
      else
        output.last[:output] << line
      end
    end
  end
  alias_method :commands, :input
end

Day7.solve
