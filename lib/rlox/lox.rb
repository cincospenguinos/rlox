# frozen_string_literal: true

module Rlox
  # Lox
  #
  # Entrypoint for execution of language.
  class Lox
    def run(source)
      tokens = Scanner.new(source).scan_tokens
      expression = Parser.new(tokens).parse

      # TODO: Error handling! Expression is nil if we get an error
      puts AstStringifier.new.stringify(expression)
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
        break if line.nil?

        run(line)
      end
    end
  end
end
