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

    OPERATOR_TOKENS = {
      /\A!\z/ => Token.new(type: :bang, string: "!"),
      /\A!=\z/ => Token.new(type: :bang_equal, string: "!="),
      /\A\=\z/ => Token.new(type: :equal, string: "="),
      /\A\==\z/ => Token.new(type: :equal_equal, string: "=="),
      /\A<\z/ => Token.new(type: :less, string: "<"),
      /\A<=\z/ => Token.new(type: :less_equal, string: "<="),
      /\A>\z/ => Token.new(type: :greater, string: ">"),
      /\A>=\z/ => Token.new(type: :greater_equal, string: ">=")
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

      if OPERATOR_TOKENS.keys.map { |re| re =~ current_slice }.any?
        if OPERATOR_TOKENS.keys.map { |re| re =~ current_slice(1) }.any?
          token = OPERATOR_TOKENS.select { |re, _| re =~ current_slice(1) }.values[0]
          @current_index += 1
        else
          token = OPERATOR_TOKENS.select { |re, _| re =~ current_slice }.values[0]
        end
      end

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

    def current_slice(peek_amount = 0)
      source[@start_index...(@current_index + peek_amount)]
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
