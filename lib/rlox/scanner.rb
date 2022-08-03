# frozen_string_literal: true

require "struct"

module Rlox
  Token = Struct.new(:type, :string, keyword_init: true)

  # Scanner
  #
  # Scans source code for tokens
  class Scanner
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
      @start_index = 0
      @current_index = 0
      @source = source
    end

    def scan_tokens
      tokens = []

      while @current_index < source.length
        advance_index
        token = scan_token(current_slice)
        unless token.nil?
          tokens << token
          @start_index = @current_index
        end
      end

      tokens
    end

    private

    def advance_index
      @current_index += 1
    end

    def current_slice
      source[@start_index...@current_index]
    end

    def scan_token(string)
      token = nil
      token = SINGLE_CHAR_TOKENS[string] if SINGLE_CHAR_TOKENS.keys.include?(string)
      token
    end
  end
end
