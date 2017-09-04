# === Define nagios::client::contact
#
define nagios::client::contact(
  $contact = $title,
  $alias   = undef,
  $email   = undef,
  $use     = 'generic-contact',
) {

  @@nagios_contact { $contact:
    use   => $use,
    alias => $alias,
    email => $email,
  }
}
