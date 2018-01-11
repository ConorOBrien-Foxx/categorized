#!/usr/bin/ruby

$parts = [
    /\d+/,
    /[a-z]+/,
    /[ \n]+/,
    /[A-Z]+/,
    /.+?/,
]
$regex = Regexp.new $parts.join "|"

def tokens(str)
    str.gsub(/\r/, "").scan(/((.)\2*)/m).map(&:first)
end

$ops = [:+, :*, :/, :-]
def categorized(str)
    toks = tokens(str)
    nums = toks.map { |e|
        [$parts.index { |part| part === e }, e.size]
    }
    # p nums
    stack = []
    i = 0
    loop {
        break unless nums[i]
        type, spec = nums[i]
        case type
            when 0
                stack << spec
            when 1
                case spec
                    # loop start
                    when 1
                        # find loop end
                        unless stack.last && stack.last != 0
                            depth = 0
                            loop {
                                depth += 1 if nums[i] == [1, 1]
                                depth -= 1 if nums[i] == [1, 2]
                                break if depth == 0
                                i += 1
                            }
                        end
                    # loop end
                    when 2
                        if stack.last && stack.last != 0
                            depth = 0
                            loop {
                                depth += 1 if nums[i] == [1, 2]
                                depth -= 1 if nums[i] == [1, 1]
                                break if depth == 0
                                i -= 1
                            }
                        end
                    else
                        raise "Unknown specifier #{spec}"
                end
            
            when 2
                case spec
                    when 1
                        stack << stack.size
                    when 2
                        print (stack.pop.chr rescue 42)
                    when 3
                        stack << STDIN.getc.ord
                    when 4
                        print stack.pop
                end
            when 3
                case spec
                    when 1
                        a, b = stack.pop(2)
                        stack.push b, a
                    when 2
                        stack.pop
                    when 3
                        a, b, c = stack.pop(3)
                        stack.push b, c, a
                end
            when 4
                case spec
                    when 1
                        stack << stack.last
                    when 2..5
                        a, b = stack.pop(2)
                        stack << a.send($ops[spec - 2], b)
                end
            else
                raise "Unknown type #{type.inspect}"
        end
        i += 1
    }
    stack
end

p categorized File.read ARGV[0]