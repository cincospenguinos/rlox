# frozen_string_literal: true

module Rlox
  Token = Struct.new(:type, :string, keyword_init: true)

  # Tokenizer
  #
  # Tokenizes provided source code into tokens
  class Tokenizer
    SINGLE_CHAR_TOKENS = {
      "(" => Token.new(type: :left_paren, string: "("),
      ")" => Token.new(type: :right_paren, string: ")"),
      "{" => Token.new(type: :left_brace, string: "{"),
      "}" => Token.new(type: :right_brace, string: "}"),
      "," => Token.new(type: :comma, string: ","),
      "." => Token.new(type: :dot, string: "."),
      "-" => Token.new(type: :dash, string: "-"),
      "+" => Token.new(type: :plus, string: "+"),
      ";" => Token.new(type: :semicolon, string: ";"),
      "*" => Token.new(type: :star, string: "*")
    }.freeze

    attr_reader :source

    def initialize(source)
      @source = source
      @start_index = 0
      @current_index = 0
      @source = source
    end

    def scan
      token = nil
      token = SINGLE_CHAR_TOKENS[current_slice].clone if SINGLE_CHAR_TOKENS.keys.include?(current_slice)
      @start_index = @current_index unless token.nil?
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
      Token.new(type: :invalid_token, string: current_slice)
    end

    def leftovers?
      !current_slice.empty?
    end

    private

    def current_slice
      source[@start_index...@current_index]
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

      tokens << tokenizer.leftovers if tokenizer.leftovers?
      tokens
    end
  end
end
