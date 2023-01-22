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

    def set_indexes(tokenizer)
      tokenizer.start_index += token.string.size
      tokenizer.current_index = tokenizer.start_index
    end

    protected

    def advance_until_whitespace_end_or_non_word
      until tokenizer.current_slice(1) =~ /\s+/ || tokenizer.at_end? || tokenizer.current_slice(1).match(/\W/)
        tokenizer.advance_index
      end
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
    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return @token unless @token.nil?
      return nil unless tokenizer.current_slice == '"'

      # TODO: We should not need this at_end_disregard function. Why the off-by-one?
      peek_amt = 1
      until tokenizer.at_end_disregard_source_length?(peek_amt) || !@token.nil?
        acquire_token_at(peek_amt)
        peek_amt += 1
      end

      raise Rlox::ScanError, "unclosed string: #{tokenizer.current_slice(peek_amt)}" if @token.nil?

      @token
    end

    private

    def acquire_token_at(peek_amt)
      slice = tokenizer.current_slice(peek_amt)
      @token = Token.new(type: :string_literal, string: slice) if slice.end_with?('"')
    end
  end

  ## NumberLiteralTokenizer
  class NumberLiteralTokenizer < SingleCharTokenizer
    NUMBER_LITERAL_PATTERN = /\A[0-9]+(\.[0-9]+)?\z/.freeze
    UNBOUNDED_DECIMAL_PATTERN = /\A[0-9]+\.\z/.freeze

    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return nil unless tokenizer.current_slice =~ /[0-9]+/

      while true
        break if tokenizer.at_end?

        slice = tokenizer.current_slice(1)
        break if slice.match(/\s/)
        break if slice.match(/\D/) && !slice.include?('.')
        tokenizer.advance_index
      end

      if UNBOUNDED_DECIMAL_PATTERN =~ tokenizer.current_slice
        raise Rlox::ScanError,
              "unbounded decimal: #{tokenizer.current_slice}"
      elsif NUMBER_LITERAL_PATTERN =~ tokenizer.current_slice
        return Token.new(type: :number_literal,
                         string: tokenizer.current_slice)
      end

      nil
    end
  end

  ## IdentifierTokenizer
  class IdentifierTokenizer < SingleCharTokenizer
    ALPHANUMERIC_PATTERN = /\A[a-z_A-Z]+[a-zA-Z_0-9]*\z/.freeze

    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      return nil unless tokenizer.current_slice =~ /[a-zA-Z_]+/

      advance_until_whitespace_end_or_non_word

      if ALPHANUMERIC_PATTERN =~ tokenizer.current_slice
        return Token.new(type: :identifier, string: tokenizer.current_slice)
      end

      nil
    end
  end

  ## ReservedWordTokenizer
  class ReservedWordTokenizer < SingleCharTokenizer
    RESERVED_WORDS = {
      "and" => Token.new(type: :and, string: "and"),
      "class" => Token.new(type: :class, string: "class"),
      "else" => Token.new(type: :else, string: "else"),
      "false" => Token.new(type: :false, string: "false"),
      "for" => Token.new(type: :for, string: "for"),
      "fun" => Token.new(type: :fun, string: "fun"),
      "if" => Token.new(type: :if, string: "if"),
      "nil" => Token.new(type: :nil, string: "nil"),
      "or" => Token.new(type: :or, string: "or"),
      "print" => Token.new(type: :print, string: "print"),
      "return" => Token.new(type: :return, string: "return"),
      "super" => Token.new(type: :super, string: "super"),
      "this" => Token.new(type: :this, string: "this"),
      "true" => Token.new(type: :true, string: "true"),
      "var" => Token.new(type: :var, string: "var"),
      "while" => Token.new(type: :while, string: "while"),
    }.freeze

    def initialize(tokenizer)
      super(tokenizer)
      @token = nil
    end

    def token
      # TODO: Guard clase?
      advance_until_whitespace_end_or_non_word

      slice = tokenizer.current_slice
      return RESERVED_WORDS[slice].clone if RESERVED_WORDS.keys.include?(slice)

      nil
    end
  end
end
