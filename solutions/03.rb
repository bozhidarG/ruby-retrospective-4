class String
  def to_boolean
    self.downcase  == 'true'
  end

  def to_number
    if self.include? '.'
      self.to_f
    else
      self.to_i
    end
  end
end

module RBFS
  class Serializer
    def self.serialize_files(files)
      files.length.to_s + ':' + Serializer.help_serailize(files)
    end

    def self.serialize_directory(directories)
      directories.length.to_s + ':' + Serializer.help_serailize(directories)
    end

    private
    def self.help_serailize(values)
      to_return = ''
      values.each_pair do |key, value|
        str = value.serialize
        to_return = to_return + key + ':' + str.length.to_s + ':' + str
      end
      to_return
    end
  end

  class Parser
    def self.make_file(string)
      values = string.split(/:/, 2)
      case values[0].to_sym
        when :nil    then File.new
        when :string then File.new(values[1].to_s)
        when :number then File.new(values[1].to_number)
        when :symbol then File.new(values[1].to_sym)
        when :boolean then File.new(values[1].to_boolean)
      end
    end

    def self.build_from_string(string)
      dir = Directory.new
      Parser.parse_files(string, dir)
    end

    private
    def self.parse_files(string, dir)
      size_file = string.split(':', 2)
      0.upto(size_file[0].to_i - 1) do
        parts = size_file[1].split(':', 3)
        dir.add_file(parts[0], File.parse(parts[2][0..parts[1].to_i - 1]))
        size_file[1] = parts[2][parts[1].to_i..parts[2].length - 1]
      end
      parse_dir(size_file[1], dir)
    end

    def self.parse_dir(string, dir)
      size_dir = string.split(':', 2)
      0.upto(size_dir[0].to_i - 1) do
        parts = size_dir[1].split(':', 3)
        dir.add_directory(parts[0], Directory.parse(parts[2][0..parts[1].to_i - 1]))
        size_dir[1] = parts[2][parts[1].to_i..parts[2].length - 1]
      end
      dir
    end
  end

  class File
    def initialize(value = nil)
      @data = value
      @data_type = data_to_symbol(value)
    end

    attr_reader :data_type, :data

    def data=(value)
      @data = value
      @data_type = data_to_symbol(value)
    end

    def serialize
      @data_type.to_s + ':' + @data.to_s
    end

    def self.parse(serialized_string)
      Parser.make_file(serialized_string)
    end

    private
    def data_to_symbol(data)
      case data.class.name
        when 'NilClass'   then :nil
        when 'String'     then :string
        when 'Fixnum'     then :number
        when 'Float'      then :number
        when 'Symbol'     then :symbol
        when 'TrueClass'  then :boolean
        when 'FalseClass' then :boolean
      end
    end
  end

  class Directory
    def initialize()
      @files = Hash.new
      @directories = Hash.new
    end

    attr_reader :files, :directories

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = Directory.new)
      @directories[name] = directory
    end

    def [](name)
      if @directories[name]
        @directories[name]
      else
        @files[name]
      end
    end

    def serialize
      Serializer.serialize_files(@files) + Serializer.serialize_directory(@directories)
    end

    def self.parse(serialized_string)
      Parser.build_from_string(serialized_string)
    end
  end
end
