class MyGeneral::Instance
  def initialize(log_file, database_file)
    @complexity = nil
    @db = nil

    @log_file = log_file
    @database_file = database_file
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
    puts "[3/4] ⏳  Importing Data... OK [#{complexity}/#{complexity}]"
    puts '[4/4] 🚩  Finished!'
  end

  def run_data
    progressbar = ProgressBar.create
    progressbar.total = complexity
    File.open(@log_file, 'r') do |file|
      until file.eof?
        line = file.readline
        run_query(line, progressbar)
        progressbar.increment
      end
    end
  end

  def run_query(line, progressbar)
    data = line.split("\t")
    return if data.length < 3 # A connecting message
    return if data[-1].upcase.start_with?('CREATE DATABASE') # Ignore database scale query
    return unless data[-2].end_with?('Query') # Ignore not query
    return if data[-1].upcase.start_with?('SELECT')# Ignore select query
    return if data[-1].upcase.start_with?('SHOW') # Ignore show query
    @db.run(data[-1])
  rescue => e
    progressbar.log("When executing #{line}")
    progressbar.log('We met a problem:')
    progressbar.log(e.inspect)
  end
end
