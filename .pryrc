Pry.hooks.add_hook(:before_eval, "cache_last_code") do |code, _pry_|
  $last_code = code
end

Pry.hooks.add_hook(:after_eval, "find_on_other_shards") do |_result, _pry_|
  if $ERROR_INFO && $ERROR_INFO.is_a?(ActiveRecord::RecordNotFound)
    original_shard = Sharding.current_shard_id

    Sharding.with_mode(:non_strict) do
      Sharding.each_shard do |shard_id|
        next if original_shard == shard_id

        begin
          _pry_.current_binding.eval($last_code, Pry.eval_path, Pry.current_line)

          print "📢 Record found on a different shard! If you want to switch to that shard, run this command: ".green
          puts "Sharding.switch_to_shard(#{shard_id})".white
        rescue ActiveRecord::RecordNotFound
          # Record not found on other shard. Swallow this exception and let pry handle the original exception.
        end
      end
    end
  end
end

if defined?(PryByebug) && !ENV["PRY_NO_BYEBUG_ALIASES"]
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'b', 'break'
end

# Hit Enter to repeat last command
Pry::Commands.command /^$/, "repeat last command" do
  _pry_.run_command Pry.history.to_a.last

end
