Event_ChannelDelete = lambda { |vars|
  vars[:bot].channel_delete { |event|
    unless event.server.nil?
      begin
        if event.id.to_s == vars[:database].get_ticket(event.id)[0][0].to_s
          vars[:database].delete_ticket(event.id)
          vars[:bot].channel(vars[:config][:logs_channel_id]).send_embed { |embed|
            embed.color = 16751360
            embed.description = "**:warning: Канал с заявкой был удален вручную. Заявка автоматически отклоняется без оповещения пользователя, подавшего заявку**"
          }
        end
      rescue
      end
    end
  }
}
