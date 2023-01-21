# frozen_string_literal: true

module Rlox
  Token = Struct.new(:type, :string, keyword_init: true)

  ## SingleCharTokenizer
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

    # Returns the token generated from the tokenizer's current slice
    def token
      slice = tokenizer.current_slice
      return SINGLE_CHAR_TOKENS[slice].clone if SINGLE_CHAR_TOKENS.keys.include?(slice)

      nil
    end

    # Returns the number of characters consumed, or zero if no token was generated
    def chars_consumed
      return 0 if token.nil?

      token.string.size
    end
  end

  ## OperatorTokenizer
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
      token
    end

    def operator_for(string)
      OPERATOR_TOKENS.select { |re, _| re =~ string }.values[0] || nil
    end
  end

  ## SlashOrCommentTokenizer
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

  ## StringLiteralTokenizer
  class StringLiteralTokenizer < SingleCharTokenizer
    STRING_LITERAL_PATTERN = %r{\A"[\w\s]+"\z}.freeze
    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return nil unless tokenizer.current_slice == '"'

      if STRING_LITERAL_PATTERN =~ tokenizer.leftovers
        return Token.new(type: :string_literal,
                         string: tokenizer.leftovers)
      end

      nil
    end
  end

  class NumberLiteralTokenizer < SingleCharTokenizer
    NUMBER_LITERAL_PATTERN = %r{\A[0-9]+(\.[0-9]+)?\z}.freeze

    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return nil unless tokenizer.current_slice =~ /[0-9]+/

      until tokenizer.current_slice(1) =~ /\s+/ || tokenizer.at_end?
        tokenizer.advance_index
      end

      if NUMBER_LITERAL_PATTERN =~ tokenizer.current_slice
        return Token.new(type: :number_literal,
                         string: tokenizer.current_slice)
      end

      nil
    end
  end
end
