class Calc::Parser

prechigh
  left "%"
  left "*" "/"
  left "+" "-"
preclow

token MEM_RECALL MEM_CLEAR MEM_PLUS MEM_MINUS NUMBER

start program

rule
  program: statements | /* none */ { result = [] }

  statements: statement                 { result = [val[0]] }
            | statements "\n" statement { result = val[0] + [val[2]] }

  statement: command | expression

  command: MEM_RECALL { result = Calc::MemRecall.new }
         | MEM_CLEAR  { result = Calc::MemClear.new }
         | MEM_PLUS   { result = Calc::MemPlus.new }
         | MEM_MINUS  { result = Calc::MemMinus.new }

  expression: continuation_expression | simple_expression

  continuation_expression: "+" simple_expression { result = Calc::Addition.new(Calc::LastResult.new, val[1]) }
                         | "-" simple_expression { result = Calc::Subtraction.new(Calc::LastResult.new, val[1]) }
                         | "*" simple_expression { result = Calc::Multiplication.new(Calc::LastResult.new, val[1]) }
                         | "/" simple_expression { result = Calc::Division.new(Calc::LastResult.new, val[1]) }
                         | "%"                   { result = Calc::Division.new(Calc::LastResult.new, Calc::Number.new(100)) }

  simple_expression: simple_expression "+" simple_expression { result = Calc::Addition.new(val[0], val[2]) }
                   | simple_expression "-" simple_expression { result = Calc::Subtraction.new(val[0], val[2]) }
                   | simple_expression "*" simple_expression { result = Calc::Multiplication.new(val[0], val[2]) }
                   | simple_expression "/" simple_expression { result = Calc::Division.new(val[0], val[2]) }
                   | NUMBER "%"                              { result = Calc::Percentage.new(val[0]) }
                   | NUMBER                                  { result = Calc::Number.new(val[0]) }

---- header

require "strscan"

module Calc
  class Machine
    attr_reader :result
    attr_accessor :memory

    def initialize
      @result = 0
      @memory = 0
    end

    def evalulate(statements)
      statements.map(&method(:evalulate_statement))
      @result
    end

    def evalulate_statement(statement)
      result = statement.evalulate(self)

      if result.respond_to?(:value)
        @result = result.value
      else
        nil
      end
    end
  end

  class Statement
    def evalulate(vm)
      self
    end
  end

  class MemRecall < Statement
    def evalulate(vm)
      Number.new(vm.memory)
    end
  end

  class MemClear < Statement
    def evalulate(vm)
      vm.memory = 0
      nil
    end
  end

  class MemPlus < Statement
    def evalulate(vm)
      vm.memory += vm.result
      nil
    end
  end

  class MemMinus < Statement
    def evalulate(vm)
      vm.memory -= vm.result
      nil
    end
  end

  class LastResult < Statement
    def evalulate(vm)
      Number.new(vm.result)
    end
  end

  class Addition < Statement
    def initialize(left, right)
      @left = left
      @right = right
    end

    def evalulate(vm)
      left = @left.evalulate(vm)
      right = @right.evalulate(vm)

      if Percentage === right
        Number.new(left.value * (1 + right.value))
      else
        Number.new(left.value + right.value)
      end
    end
  end

  class Subtraction < Statement
    def initialize(left, right)
      @left = left
      @right = right
    end

    def evalulate(vm)
      left = @left.evalulate(vm)
      right = @right.evalulate(vm)

      if Percentage === right
        Number.new(left.value * (1 - right.value))
      else
        Number.new(left.value - right.value)
      end
    end
  end

  class Multiplication < Statement
    def initialize(left, right)
      @left = left
      @right = right
    end

    def evalulate(vm)
      left = @left.evalulate(vm)
      right = @right.evalulate(vm)

      if Percentage === left || Percentage === right
        Percentage.new(100 * (left.value * right.value))
      else
        Number.new(left.value * right.value)
      end
    end
  end

  class Division < Statement
    def initialize(left, right)
      @left = left
      @right = right
    end

    def evalulate(vm)
      left = @left.evalulate(vm)
      right = @right.evalulate(vm)

      if right.value == 0
        raise RuntimeError, "Division by zero"
      end

      if Percentage === left || Percentage === right
        Percentage.new(100 * (left.value / right.value))
      else
        Number.new(left.value.to_f / right.value)
      end
    end
  end

  class Value < Statement
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def evalulate(vm)
      if Value === @value
        self
      else
        self.class.new(@value.evalulate(vm))
      end
    end
  end

  class Percentage < Value
    def value
      super / 100.0
    end
  end

  class Number < Value
  end
end

---- inner

  def parse(str)
    tokenize(str)
    do_parse
  end

  private def tokenize(str)
    # Strip comments
    str.gsub!(/#.*$/, "")

    # Strip blank lines
    str.gsub!(/\n+/, "\n")

    # Strip leading and trailing new lines
    str.strip!

    scanner = StringScanner.new(str)

    @tokens = []

    until scanner.eos?
      if scanner.scan(/MR/)
        @tokens << [:MEM_RECALL, nil]
      elsif scanner.scan(/MC/)
        @tokens << [:MEM_CLEAR, nil]
      elsif scanner.scan(/M\+/)
        @tokens << [:MEM_PLUS, nil]
      elsif scanner.scan(/M-/)
        @tokens << [:MEM_MINUS, nil]
      elsif scanner.scan(/[0-9]+(?!\.)/)
        @tokens << [:NUMBER, scanner.matched.to_i]
      elsif scanner.scan(/[0-9]*\.[0-9]+/)
        @tokens << [:NUMBER, scanner.matched.to_f]
      elsif scanner.scan(/\n/)
        @tokens << ["\n", "\n"]
      elsif scanner.scan(/#[^\n]+(?=\n)/)
        next
      elsif scanner.skip(/\s+/)
        next
      else
        s = scanner.scan(/./)
        @tokens << [s, s]
      end
    end

    @tokens.push [false, "$end"]
  end

  private def next_token
    @tokens.shift
  end

---- footer

parser = Calc::Parser.new
machine = Calc::Machine.new

print ">> "

while input = gets
  begin
    if result = machine.evalulate_statement(parser.parse(input).first)
      puts "=> #{result}"
    end
  rescue
    puts "ERROR"
  end

  print ">> "
end
