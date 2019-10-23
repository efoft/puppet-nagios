#
define nagios::command (
  String[1] $command_title,
  String[1] $command_line,
) {

  ensure_resource('nagios_command', $command_title, { 'command_line' => "\$USER1$/${command_line}" })
}
