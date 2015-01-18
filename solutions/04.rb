module UI
  class TextScreen
    @@string = ""

    class << self
      def draw(&block)
        if block_given?
          class_eval(&block)
          StringParser.new(@@string).handle_string
        end
      end

      def label(args)
        @@string << "<label #{args}>#{args[:text]}</label>"
      end

      def vertical(*args, &block)
        @@string << "<vertical #{args}>"
        if block_given?
          class_eval(&block)
        end
        @@string << "</vertical>"
      end

      def horizontal(*args, &block)
        @@string << "<horizontal #{args}>"
        if block_given?
          class_eval(&block)
        end
        @@string << "</horizontal>"
      end
    end
  end

  class StringParser
    def initialize(string)
      @work_string = string
    end

    attr_reader :work_string

    def handle_string
      start
    end
    private

    def start
      data = /^<(\w+).*?\1>/.match(@work_string)
      send(data[1], @work_string)
    end

    def vertical(string)
      Vertical.new(string).parse
    end

    def horizontal(string)
      Horizontal.new(string).parse
    end

    def label(string)
      Label.new(string).parse
    end
  end

  class Vertical
    def initialize(string)
      @string = string
      @new_string = ''
    end

    def parse
      data = /^<vertical \[(.*?)\]>(.*)/.match(@string)
      level = data[2]
      generate_string(level)
    end

    private
    def generate_string(level)
      while level != '</vertical>'
        elem = /^(<(\w+) .*?>.+?<\/\2>)(.*)/.match(level)[1]
        @new_string << StringParser.new(elem).handle_string << "\n"
        level = /^(<(\w+) .*?>.+?<\/\2>)(.*)/.match(level)[3]
      end
      @new_string
    end
  end

  class Horizontal
    def initialize(string)
      @string = string
      @new_string = ''
    end

    def parse
      data = /^<horizontal \[(.*?)\]>(.*)/.match(@string)
      attributes = eval(data[1])
      level = data[2]
      set_attributes(attributes, generate_string(level))
    end

    private

    def generate_string(level)
      while level != '</horizontal>'
        elem = /^(<(\w+) .*?>.+?<\/\2>)(.*)/.match(level)[1]
        @new_string << StringParser.new(elem).handle_string
        level = /^(<(\w+) .*?>.+?<\/\2>)(.*)/.match(level)[3]
      end
      @new_string
    end

    def set_attributes(attributes, elem)
      border = (attributes.has_key?(:border) ? attributes[:border] : '' )
      border + elem + border
    end
  end

  class Label
    def initialize(string)
      @string = string
      @new_string = ''
    end

    def parse
      data = /^(<label ({.*?})>.*?<\/label>)(.*)/.match(@string)
      generate_string(data[0])
    end

    private

    def generate_string(level)
      while level != ''
        elem = /^(<(\w+) (.*?})>(.+?)<\/\2>)(.*)/.match(level)[4]
        attributes = eval(/^(<(\w+) (.*?})>(.+?)<\/\2>)(.*)/.match(level)[3])
        @new_string << set_attributes(attributes, elem)
        level = /^(<(\w+) .*?}>.+?<\/\2>)(.*)/.match(level)[3]
      end
      @new_string
    end

    def set_attributes(attributes, elem)
      border = (attributes.has_key?(:border) ? attributes[:border] : '' )
      border + elem + border
    end
  end
end
