# frozen_string_literal: true

module Rlox
  # Lox
  #
  # Entrypoint for execution of language.
  class Lox
    def run(source)
      # TODO: Error handling!
      tokens = Scanner.new(source).scan
      statements = Parser.new(tokens).parse!
      puts interpreter.evaluate!(statements).inspect
    end

    def run_file(filepath)
      raise Rlox::RloxError, "#{filepath} is not a valid file" unless File.file?(filepath)

      source = File.read(filepath)
      run(source)
    end

    def run_prompt
      loop do
        print "> "
        line = gets
        break if line.nil? || line =~ /\A\s*\z/

        run(line)
      end
    rescue RloxError => e
      puts e
      run_prompt
    end

    private

    def interpreter
      @interpreter ||= Interpreter.new
    end
  end
end
