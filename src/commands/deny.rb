Command_Deny = lambda { |vars|
  if vars[:config][:register_commands?]
    vars[:bot].register_application_command(:deny, "Отклонить заявку", server_id: vars[:config][:server_id]) { |cmd|
      cmd.string(:reason, "Причина, по которой заявка была отклонена", required: true)
    }
  end

  vars[:bot].application_command(:deny) { |handler|
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
        handler.send_message(content: "**:x: Заявка отклонена. Канал будет автоматически удален через 30 секунд**")

        # DM the user
        vars[:bot].pm_channel(user_id).send_embed { |embed|
          embed.description = "**:x: Ваша заявка на ViewPoint была отклонена**"
          embed.add_field(name: "Причина", value: handler.options["reason"], inline: true)
          embed.color = 14429223
        }

        # Delete the ticket from DB
        vars[:database].delete_ticket(handler.channel.id)

        # Send logs
        vars[:bot].channel(vars[:config][:logs_channel_id]).send_embed { |embed|
          embed.color = 14429223
          embed.description = "**Заявка на ViewPoint была отклонена <@#{handler.user.id}>**"
          embed.add_field(name: "Пользователь", value: "<@#{user_id}>", inline: true)
          embed.add_field(name: "Никнейм", value: nickname, inline: true)
          embed.add_field(name: "Причина", value: handler.options["reason"], inline: false)
        }

        # Delete the channel from discord
        sleep(30)
        vars[:bot].channel(handler.channel.id, vars[:config][:server_id]).delete("Заявка закрыта")
      end
    end
  }
}
