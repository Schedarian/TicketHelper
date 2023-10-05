Command_Approve = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:approve, "Принять заявку", server_id: vars[:config][:server_id])
  end

  vars[:bot].application_command(:approve) { |handler|
    handler.defer(ephemeral: true)

    if vars[:bot].member(handler.server_id, handler.user.id).permission?(:ban_members) == false
      handler.send_message(content: "У вас нет прав на использование данной команды")
    else
      if handler.channel.name.start_with?("ticket-")

        # Get ticket data
        ticket = vars[:database].get_ticket(handler.channel.id)
        channel_id = ticket[0][0]
        user_id = ticket[0][1]
        nickname = ticket[0][2]

        # Notify the moderator
        handler.send_message(content: "**:white_check_mark: Заявка одобрена. Канал будет автоматически удален через 30 секунд**")

        # DM the user
        vars[:bot].pm_channel(user_id).send_embed { |embed|
          embed.description = "**:white_check_mark: Ваша заявка на ViewPoint была одобрена. Добро пожаловать на сервер!**"
          embed.color = 5767001
        }

        # Delete the ticket from DB
        vars[:database].delete_ticket(handler.channel.id)

        # Add player role to the user
        vars[:bot].member(vars[:config][:server_id], user_id).add_role(vars[:config][:player_role_id])

        # Send logs
        vars[:bot].channel(vars[:config][:logs_channel_id]).send_embed { |embed|
          embed.color = 5767001
          embed.description = "**Заявка на ViewPoint была одобрена <@#{handler.user.id}>**"
          embed.add_field(name: "Пользователь", value: "<@#{user_id}>", inline: true)
          embed.add_field(name: "Никнейм", value: nickname, inline: true)
        }

        # Write into a console channel
        vars[:bot].channel(vars[:config][:console_channel_id], vars[:config][:server_id]).send_message("whitelist add #{nickname}")

        # Delete the channel from discord
        sleep(30)
        vars[:bot].channel(handler.channel.id, vars[:config][:server_id]).delete("Заявка закрыта")
      end
    end
  }
}
