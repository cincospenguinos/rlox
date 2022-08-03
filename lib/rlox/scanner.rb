# frozen_string_literal: true
require 'ostruct'

module Rlox
  # Scanner
  #
  # Scans source code for tokens
  class Scanner
    SINGLE_CHAR_TOKENS = {
      '(' => OpenStruct.new(type: :left_paren, string: '('),
      ')' => OpenStruct.new(type: :right_paren, string: ')'),
      '{' => OpenStruct.new(type: :left_brace, string: '{'),
      '}' => OpenStruct.new(type: :right_brace, string: '}'),
      ',' => OpenStruct.new(type: :comma, string: ','),
      '.' => OpenStruct.new(type: :dot, string: '.'),
      '-' => OpenStruct.new(type: :dash, string: '-'),
      '+' => OpenStruct.new(type: :plus, string: '+'),
      ';' => OpenStruct.new(type: :semicolon, string: ';'),
      '*' => OpenStruct.new(type: :star, string: '*'),
    }

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
