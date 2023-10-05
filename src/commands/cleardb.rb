Command_Cleardb = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:cleardb, "Очистить базу данных. Убирает ВСЕ заявки. Использовать с осторожностью", server_id: vars[:config][:server_id])
  end

  vars[:bot].application_command(:cleardb) { |handler|
    handler.defer(ephemeral: true)

    if vars[:bot].member(handler.server_id, handler.user.id).permission?(:administrator) == false
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      vars[:bot].channel(vars[:config][:logs_channel_id]).send_embed { |embed|
        embed.color = 16751360
        embed.description = "**:warning: База данных была очищена пользователем <@#{handler.user.id}>**"
      }
    end
  }
}
