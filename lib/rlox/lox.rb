# frozen_string_literal: true

module Rlox
  # Lox
  #
  # Entrypoint for execution of language.
  class Lox
    def run(source)
      puts source
    end

    def run_file(filepath)
      raise Rlox::Error, "#{filepath} is not a valid file" unless File.file?(filepath)

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
