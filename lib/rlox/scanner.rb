# frozen_string_literal: true

module Rlox
  Token = Struct.new(:type, :string, keyword_init: true)

  class SingleCharTokenizer
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

    attr_reader :tokenizer

    def initialize(tokenizer)
      @tokenizer = tokenizer
    end

    def token
      slice = tokenizer.current_slice
      return SINGLE_CHAR_TOKENS[slice].clone if SINGLE_CHAR_TOKENS.keys.include?(slice)

      nil
    end

    def chars_consumed
      token.string.size
    end
  end

  class OperatorTokenizer < SingleCharTokenizer
    OPERATOR_TOKENS = {
      /\A!\z/ => Token.new(type: :bang, string: "!"),
      /\A!=\z/ => Token.new(type: :bang_equal, string: "!="),
      /\A=\z/ => Token.new(type: :equal, string: "="),
      /\A==\z/ => Token.new(type: :equal_equal, string: "=="),
      /\A<\z/ => Token.new(type: :less, string: "<"),
      /\A<=\z/ => Token.new(type: :less_equal, string: "<="),
      /\A>\z/ => Token.new(type: :greater, string: ">"),
      /\A>=\z/ => Token.new(type: :greater_equal, string: ">=")
    }.freeze

    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return @token unless @token.nil?

      @token = operator_for(tokenizer.current_slice(1))
      @token = operator_for(tokenizer.current_slice) if @token.nil?
      @token
    end

    private

    def operator_token
      token = operator_for(current_slice(1))
      token = operator_for(current_slice) if token.nil?
      @current_index += 1 if !token.nil? && token.string.size > 1
      token
    end

    def operator_for(string)
      OPERATOR_TOKENS.select { |re, _| re =~ string }.values[0] || nil
    end
  end

  class SlashOrCommentTokenizer < SingleCharTokenizer
    COMMENT_PATTERN = %r{\A//[\w\s]+\z}.freeze

    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return nil unless tokenizer.current_slice == "/"
      return Token.new(type: :comment, string: tokenizer.leftovers) if COMMENT_PATTERN =~ tokenizer.leftovers

      Token.new(type: :slash, string: tokenizer.current_slice)
    end
  end

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
