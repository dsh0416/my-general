class MyGeneral::Instance
  def initialize(log_file, database_file)
    @complexity = nil
    @db = nil
    @time = nil
    @new_command = false
    @command = 'Query'
    @buffer = 'SELECT 1'

    @insert_count = 0
    @success_count = 0

    @log_file = log_file
    @database_file = database_file
    @progressbar = nil
  end

  def complexity
    @complexity.nil? ? (@complexity = `wc -l #{@log_file}`.to_i) : @complexity
  end

  def run
    puts "Log File:           #{@log_file}"
    puts "Database YAML:      #{@database_file}"
    puts '[1/4] ⌚  Counting Complexity...'
    complexity
    puts "[1/4] ⌚  Counting Complexity... OK [Complexity: #{@complexity}]"
    puts '[2/4] 🔌  Dailing Database...'
    @db = Sequel.connect(YAML.load_file(@database_file))
    puts "[2/4] 🔌  Dailing Database... OK [Connected]"
    puts '[3/4] ⏳  Importing Data...'
    run_data
    puts "[3/4] ⏳  Importing Data... OK [#{@success_count}/#{@insert_count}]"
    puts '[4/4] 🚩  Finished!'
  end

  def run_data
    @progressbar = ProgressBar.create(format: '%t: |%B| %c/%C %E')
    @progressbar.total = complexity
    File.open(@log_file, 'r') do |file|
      3.times { file.readline } # Skip 3 lines
      until file.eof?
        line = file.readline
        parse_line(line)
        @progressbar.increment
      end
    end
  end

  def parse_line(line)
    date = line.split("\t")[0]
    if date =~ /^[0-9]{6}/ # Is Date?
      @time = DateTime.parse("#{20}#{date}")
      @command = line.split("\t")[1].split(' ')[-1]
      @new_command = true
    elsif line.start_with?("\t\t")
      @command = line.split("\t")[2].split(' ')[-1]
      @new_command = true
    else
      @new_command = false
    end

    flush

    if @command == 'Query'
      @buffer << line.split("\t")[-1]
    end
  rescue => e
    # Ignore
  end

  def flush
    if @new_command & !@buffer.empty?
      # Do query
      run_query
      # Refresh variables
      @new_command = false
      @buffer = ''
    end
  end

  VERBS = ['SET', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'ALTER', 'DROP'].freeze

  def run_query
    # return if @time < DateTime.parse("2017-05-13 07:08:00") # Ignore from last backup
    return if @buffer.upcase.start_with?('CREATE DATABASE') # Ignore database scale query
    return unless VERBS.map do |verb|
      @buffer.upcase.start_with?(verb)
    end.reduce(:|) # Ignore unless exact verb
    @insert_count += 1
    @db.run(@buffer)
    @success_count += 1
  rescue => e
    @progressbar.log("When executing #{@time} #{@buffer}")
    @progressbar.log('We met a problem:')
    @progressbar.log(e.inspect)
  end
end
