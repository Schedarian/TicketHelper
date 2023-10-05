# Load all command files
Dir["./src/commands/*.rb"].each { |file| require file }

module CommandHandler
  Commands = [
    Command_Approve,
    Command_Deny,
    Command_Cleardb,
  ]

  def self.init_commands(vars)
    Commands.each_with_index { |command, i|
      command.call(vars)
      (vars[:logger].info "Регистрация команд: #{i + 1}/#{Commands.size}"; sleep(5)) if vars[:config][:register_commands?]
    }

    if vars[:config][:register_commands?]
      vars[:config][:register_commands?] = false
      File.write("config.yaml", vars[:config].to_yaml)
      vars[:logger].info "Все команды зарегистрированы, параметр изменён на false"
    else
      vars[:logger].info "Команды загружены"
    end
  end
end
