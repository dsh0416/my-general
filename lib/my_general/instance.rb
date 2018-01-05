class MyGeneral::Instance
  def initialize(log, database)
    @log = log
    @database = database
    @complexity = complexity
    puts @complexity
  end

  def complexity
    `wc -l #{@log}`
  end
end
