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
    puts '[1/4] ⌚  Count Complexity...'
    complexity
    puts "[1/4] ⌚  Count Complexity... OK [Complexity: #{@complexity}]"
    puts '[2/4] 🔌  Dailing Database...'
    @db = Sequel.connect(YAML.load_file(@database_file))
    puts "[2/4] 🔌  Dailing Database... OK [Connected]"
    puts '[3/4] ⏳  Importing Data  ...'
    run_data
    puts "[3/4] ⏳  Importing Data  ... OK [#{complexity}/#{complexity}]"
    puts '[4/4] 🚩  Finished!'
  end

  def run_data
    progressbar = ProgressBar.create
    progressbar.total = complexity
    File.open(@log_file, 'r') do |file|
      until file.eof?
        line = file.readline

        progressbar.increment
      end
    end
  end
end
