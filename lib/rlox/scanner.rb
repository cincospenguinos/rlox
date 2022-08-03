# frozen_string_literal: true

require_relative "token"

module Rlox
  # Tokenizer
  #
  # Tokenizes provided source code into tokens
  class Tokenizer
    attr_reader :source

    def initialize(source)
      @source = source
      @start_index = 0
      @current_index = 0
      @source = source
    end

    def scan
      token = nil
      tokenizers.each do |tokenizer|
        if (token = tokenizer.token)
          @current_index += tokenizer.chars_consumed - 1
          break
        end
      end

      @start_index = @current_index if !token.nil? || current_slice =~ /\s+/
      token
    end

    def advance_index
      @current_index += 1
      self
    end

    def at_end?
      @current_index >= source.length
    end

    def leftovers
      current_slice(source.length - @current_index)
    end

    def leftovers_as_invalid_token
      Token.new(type: :invalid_token, string: current_slice)
    end

    def leftovers?
      !current_slice.empty?
    end

    def current_slice(peek_amount = 0)
      source[@start_index...(@current_index + peek_amount)]
    end

    private

    def tokenizers
      [SingleCharTokenizer.new(self), OperatorTokenizer.new(self), SlashOrCommentTokenizer.new(self)]
    end
  end

  # Scanner
  #
  # Scans source code for tokens
  class Scanner
    attr_reader :tokenizer

    def initialize(source)
      @tokenizer = Tokenizer.new(source)
    end

    def scan_tokens
      tokens = []

      until tokenizer.at_end?
        token = tokenizer.advance_index.scan
        tokens << token unless token.nil?
      end

      tokens << tokenizer.leftovers_as_invalid_token if tokenizer.leftovers?
      tokens
    end
  end
end
